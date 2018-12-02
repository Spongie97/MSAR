function [landmarkVec, specMat_opt, threshold, peakTable, specMat]=afpFeaExtractForward(y, fs, afpOpt, showPlot,sthOpt,specMatOpt) 
% afpFeaExtractForward: Extract landmarks by forward pass only
%
%	Usage:
%		[landmarkVec, specMat_opt, threshold, peakTable, specMat] = afpFeaExtractForward(y, fs, afpOpt)
%
%	Description:
%		Make a set of spectral feature pair landmarks from some audio data
%		y is an audio waveform at sampling rate fs
%		landmarkVec returns as a set of landmarks, as rows of a 4-column matrix
%		{startTime startFreq endFreq deltaTime}
%		lmDensity is the target hashes-per-sec (approximately; default 5)
%		specMat returns the filtered log-magnitude surface
%		threshold returns the decaying threshold surface
%		peakTable returns a list of the actual time-frequency peaks extracted.
%
%	Example:
%		waveFile = 'bad_romance_short.wav';
%		%[y, fs, nbits]=wavread(waveFile);
%		au=myAudioRead(waveFile); y=au.signal; fs=au.fs;
%		afpOpt=afpOptSet;
%		[landmarkVec, specMat, threshold, peakTable]=afpFeaExtractForward(y, fs, afpOpt, 1);
%
%	See also afpQueryMatchIncremental.
%	Category: Incremental Query
%	Pei-yu Liao, 20130704

if nargin<1, selfdemo; return; end
if nargin<3; afpOpt=afpOptSet; end	% lmDensity=7: target query landmark density. lmDensity=7 to get a_dec = 0.998
if nargin<4, showPlot=0; end
if nargin<5, sthOpt = []; end
if nargin<6, specMatOpt = []; end

%% Some parameters
maxPairsPerPeak=afpOpt.maxPairsPerPeak;	% (3) Limit the number of pairs that we'll accept from each peak
f_sd=afpOpt.f_sd;	% (30) spreading width applied to the masking skirt
a_dec = 1-0.01*(afpOpt.lmDensity/35);	% decay rate of the masking skirt behind each peak
maxPeaksPerFrame=afpOpt.maxPeaksPerFrame;	
hpf_pole=afpOpt.hpf_pole;		%  (0.98) A pole close to +1.0 results in a relatively flat high-pass filter that just removes very slowly varying parts
freqHalfSpan=afpOpt.freqHalfSpan;	% (31) +/- 50 bins in freq (LIMITED TO -32..31 IN LANDMARK2HASH)
timeSpan=afpOpt.timeSpan;  % (63) (LIMITED TO <64 IN LANDMARK2HASH)
fft_ms=afpOpt.frameDuration;	% 128-ms window (1024 point) for good spectral resolution	
hop_ms=afpOpt.frameShift;		% 64-ms hop size (512 points);	frame rate = fs/512 = 15.625
%% Resample if necessary
y=mean(y,2)';	% Convert y to a mono row-vector
if (fs~=afpOpt.targetFs)
	y=resample(y, afpOpt.targetFs, fs);	%  Y = RESAMPLE(X,P,Q) resamples the sequence in vector X at P/Q times the original sample rate using a polyphase implementation.  Y is P/Q times the length of X
	fs=afpOpt.targetFs;
%	idx = floor(fs/afpOpt.targetFs);	% take one point for each five points (assume original sample rate is 44100 Hz)
%	y = y(1:idx:end);
end

% Take spectral features
frameSize = round(fs*fft_ms/1000);		% frameSize=1024 for FFT
overlap=frameSize-round(fs/1000*hop_ms);
specMat=abs(spectrogram(y, hamming(frameSize), overlap, frameSize, fs));
frameNum=size(specMat,2);
if isempty(specMatOpt)	% 表第一個分段
	mSpecMax = max(specMat(:));		
	specMat = log(max(mSpecMax/1e6, specMat));
	specMat_opt = [sum(specMat(:)), length(specMat(:)), mSpecMax];	% 將specMat的總和、長度、最大值資訊存到specMat_opt
	specMat = specMat - mean(specMat(:));		% Make it zero-mean, so the start-up transients for the filter are minimized
else	% 表第二個分段
	mSpecMax = max(max(specMat(:)), specMatOpt(3));		
	specMat = log(max(mSpecMax/1e6, specMat));		
	specMat = specMat - ((specMatOpt(1) + sum(specMat(:))) / (specMatOpt(2) + length(specMat(:))));		% (舊+新的specMat總和)/(舊+新的長度) = new mean
	specMat_opt = [];
end

% This is just a high pass filter, applied in the log-magnitude
% domain.  It blocks slowly-varying terms (like an AGC), but also 
% emphasizes onsets.  Placing the pole closer to the unit circle 
% (i.e. making the -.8 closer to -1) reduces the onset emphasis.
specMat = filter([1 -1], [1 -hpf_pole], specMat')';	%  High-pass filter on each freq bin. To plot the frequency response: freqz([1 -1], [1 -hpf_pole]);
maxPeakPerSec = 30;			% % Estimate for how many peakTable we keep (to preallocate array) 
duration = length(y)/fs;	
peakTable = zeros(3, round(maxPeakPerSec*duration));
peakTableNum = 0;

%% find all the local prominent peaks, store as columns of peakTable.
% initial threshold envelope based on peaks in first 10 frames	
temp = specMat(:,1:min(10,frameNum));	% temp is the first 10 frames of specMat
if isempty(sthOpt)  % 表第一個分段：使用原機制的threshold
	sTh = afpEnvelopeGen(max(temp,[],2), f_sd)';	
else % 表第二個分段：使用上一個分段留下來的threshold繼續decay下去
	sTh = sthOpt * a_dec;
end
% threshold stores the actual decaying threshold, for debugging
threshold = 0*specMat;
for i = 1:frameNum-1	
	theSpec = specMat(:,i);
	sDiff = max(0, theSpec-sTh)';	
%	sDiff = locmax(sDiff);
%	sDiff(end) = 0;		
	index=localMax(sDiff, 'keepBoth'); sDiff(~index)=0;	% Only keep the local max
	% take up to 10 largest
	[vv,xx] = sort(sDiff, 'descend');	
	% (keep only nonzero)
	xx = xx(vv>0.5*max(sDiff));		% original: xx = xx(vv>0);	
	% store those peaks and update the decay envelope
	nMaxThisTime = 0;	
	for j = 1:length(xx)
		p = xx(j);		
 		if nMaxThisTime < maxPeaksPerFrame	
			nMaxThisTime = nMaxThisTime + 1;
			peakTableNum = peakTableNum + 1;
			peakTable(1, peakTableNum) = i;
			peakTable(2, peakTableNum) = p;
			peakTable(3, peakTableNum) = theSpec(p);
			eww = exp(-0.5*(([1:length(sTh)]'- p)/f_sd).^2);	% Gaussian PDF centered at p
			sTh = max(sTh, theSpec(p)*eww);		% update threshold
		end
	end
	threshold(:,i) = sTh;		
	sTh = a_dec*sTh;			
end


%% Pack nearby peak pairs into landmarks
landmarkVec = zeros(peakTableNum*maxPairsPerPeak, 4);	% Each row of landmarkVec is [t1 f1 f2 t2-t1]
nLandmark = 0;
for i =1:peakTableNum
	t1 = peakTable(1,i);
	f1 = peakTable(2,i);
	maxTime = t1 + timeSpan;
	minFreq = f1 - freqHalfSpan;
	maxFreq = f1 + freqHalfSpan;
	matchedIndex = find((peakTable(1,:)>t1+5)&(peakTable(1,:)<maxTime)&(peakTable(2,:)>minFreq)&(peakTable(2,:)<maxFreq));	
	if length(matchedIndex)>maxPairsPerPeak	
		% limit the number of pairs we make; take first ones, as they will be closest in time
		matchedIndex = matchedIndex(1:maxPairsPerPeak);
	end	
	for match = matchedIndex
		nLandmark = nLandmark+1;
		landmarkVec(nLandmark,1) = t1;
		landmarkVec(nLandmark,2) = f1;
		landmarkVec(nLandmark,3) = peakTable(2,match);		% f2
		landmarkVec(nLandmark,4) = peakTable(1,match)-t1;  % t2-t1		
	end
end
landmarkVec = landmarkVec(1:nLandmark, :);	

if showPlot
	fprintf('%s: %g sec, %d cols,  %d peakTable, %d lmarks\n', mfilename, duration, frameNum, peakTableNum, nLandmark);
	imagesc(specMat); colorbar; axis image; xlabel('Time index'); ylabel('Freq index');
	line(peakTable(1,:), peakTable(2,:), 'color', 'k', 'marker', 'o', 'linestyle', 'none');
	for i=1:nLandmark
		line(landmarkVec(i,1)+[0, landmarkVec(i,4)], landmarkVec(i,2:3), 'color', 'b'); 
	end
end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);

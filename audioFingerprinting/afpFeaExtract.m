function [lmList, specMat, threshold1, peakTable1, threshold2, peakTable2]=afpFeaExtract(y, fs, afpOpt, showPlot) 
% afpFeaExtract: Extract landmarks from audio file for audio fingerprinting
%
%	Usage:
%		lmList = afpFeaExtract(y, fs)
%		lmList = afpFeaExtract(y, fs, afpOpt)
%		[lmList,specMat,threshold1,peakTable1] = afpFeaExtract(y, fs, afpOpt)
%
%	Description:
%		This function returns a set of landmarks (pairs of salient peaks) from audio signals y with a sampling rate fs
%		Each row of the returned lmList has 4 elements [startTime startFreq endFreq deltaTime], or [t1 f1 f2 t2-t1]
%		specMat returns the filtered log-magnitude surface
%		threshold1 returns the decaying threshold surface
%		peakTable1 returns a list of the actual time-frequency peaks extracted, with row1=frame index, row2=freq index, row3=height.
%
%	Example:
%		waveFile = 'bad_romance_short.wav';
%		au=myAudioRead(waveFile); y=au.signal; fs=au.fs;
%		afpOpt=afpOptSet;
%		[lmList, specMat, threshold1, peakTable1]=afpFeaExtract(y, fs, afpOpt, 1);
%
%	See also afpQueryMatch, afpQueryMatchIncremental.

%	Category: Audio Fingerprinting
%	Roger Jang, Pei-yu Liao, 20130225

if nargin<1, selfdemo; return; end
if nargin<3; afpOpt=afpOptSet; end
if nargin<4, showPlot=0; end

%% Some parameters
maxPairsPerPeak=afpOpt.maxPairsPerPeak;	% (3) Limit the number of pairs that we'll accept from each peak
f_sd=afpOpt.f_sd;	% (30) spreading width applied to the masking skirt
a_dec = 1-0.01*(afpOpt.lmDensity/35);	% decay rate of the masking skirt behind each peak
maxPeaksPerFrame=afpOpt.maxPeaksPerFrame;	
hpf_pole=afpOpt.hpf_pole;		%  (0.98) A pole close to +1.0 results in a relatively flat high-pass filter that just removes very slowly varying parts
freqHalfSpan=afpOpt.freqHalfSpan;	% (31) +/- 50 bins in freq (LIMITED TO -32..31 IN LANDMARK2HASH)
timeSpan=afpOpt.timeSpan;  % (63) (LIMITED TO <64 IN LANDMARK2HASH)
%% Stereo to mono conversion
%% zenhon
if size(y,2)>1
	if(afpOpt.StereoToMonoConcat)
		y=y(:);
	elseif afpOpt.StereoToMonoOneChannel
		if std(y(:,1))>std(y(:,2))
			y=y(:,1);
		else
			y=y(:,2);
		end
	else
		y=mean(y,2);	% Convert y to a mono row-vector
	end
end
%%

%% Resample if necessary
if (fs~=afpOpt.targetFs)				
	y=resample(y, afpOpt.targetFs, fs);	%  Y = RESAMPLE(X,P,Q) resamples the sequence in vector X at P/Q times the original sample rate using a polyphase implementation.  Y is P/Q times the length of X
	fs=afpOpt.targetFs;
%	idx = floor(fs/afpOpt.targetFs);	% take one point for each five points (assume original sample rate is 44100 Hz)
%	y = y(1:idx:end);
end

% Take spectral features
frameSize=round(fs*afpOpt.frameDuration/1000);		% frameSize=1024 for FFT
overlap=frameSize-round(fs*afpOpt.frameShift/1000);
specMat=abs(spectrogram(y, hamming(frameSize), overlap, frameSize, fs));
%keyboard
frameNum=size(specMat,2);
mSpecMax=max(specMat(:));		
specMat=log(max(mSpecMax/1e6, specMat));		
specMat=specMat-mean(specMat(:));		% Make it zero-mean, so the start-up transients for the filter are minimized
%% Zenhon
if  afpOpt.useSpecMinThreshold
    specMat(specMat<afpOpt.specMatThreshold)=afpOpt.specMatThreshold;
end
%%
% This is just a high pass filter, applied in the log-magnitude
% domain.  It blocks slowly-varying terms (like an AGC), but also 
% emphasizes onsets.  Placing the pole closer to the unit circle 
% (i.e. making the -.8 closer to -1) reduces the onset emphasis.
specMat = filter([1 -1], [1 -hpf_pole], specMat')';	%  High-pass filter on each freq bin. To plot the frequency response: freqz([1 -1], [1 -hpf_pole]);
%% Zenhon
if  afpOpt.vertical_highpass
	specMat = filter([1 -1], [1 -hpf_pole], specMat);	%  High-pass filter on each freq bin. To plot the frequency response: freqz([1 -1], [1 -hpf_pole]);
end
%%
maxPeakPerSec = 30;			% % Estimate for how many peakTable we keep (to preallocate array) 
duration = length(y)/fs;	
peakTable1 = zeros(3, round(maxPeakPerSec*duration));
peakTableNum = 0;

%% find all the local prominent peaks, store as columns of peakTable.
% initial threshold envelope based on peaks in first 10 frames	
temp = specMat(:,1:min(10,frameNum));	% the first 10 frames of specMat
sTh = afpEnvelopeGen(max(temp,[],2), f_sd);	% initial threshold
%initSpec=max(temp,[],2); save initSpec initSpec 
threshold1 = 0*specMat;		% the actual decaying threshold, for debugging/visualization
for i = 1:frameNum	
	theSpec = specMat(:,i);
	sDiff = max(0, theSpec-sTh)';	
%	sDiff = locmax(sDiff);
%	sDiff(end) = 0;		
	index=localMax(sDiff, 'keepBoth'); sDiff(~index)=0;	% Only keep the local max
	% take up to 10 largest
	[vv,xx] = sort(sDiff, 'descend');	
	% (keep only nonzero)
	xx = xx(vv>0);	
	% store those peaks and update the decay envelope
	nMaxThisTime = 0;	
	for j = 1:length(xx)
		p = xx(j);		
 		if nMaxThisTime < maxPeaksPerFrame	
			nMaxThisTime = nMaxThisTime + 1;
			peakTableNum = peakTableNum + 1;
			peakTable1(1, peakTableNum) = i;
			peakTable1(2, peakTableNum) = p;
			peakTable1(3, peakTableNum) = theSpec(p);
			theGaussian = exp(-0.5*(([1:length(sTh)]'- p)/f_sd).^2);	% Gaussian PDF centered at p
			sTh = max(sTh, theSpec(p)*theGaussian);		% update threshold
		end
	end
	threshold1(:,i) = sTh;
	sTh = a_dec*sTh;			
end

% Backwards pruning of peakTable
peakTable2 = [];
peakTable2num = 0;
whichmax = peakTableNum;	
sTh = afpEnvelopeGen(specMat(:,end), f_sd);
threshold2 = 0*specMat;		% the actual decaying threshold, for debugging/visualization
for i = frameNum:-1:1	
	while whichmax>0 && peakTable1(1, whichmax)==i	
		freqIndex = peakTable1(2,whichmax);	% index of bin
		height = peakTable1(3,whichmax);	% magnitude
		if height>=sTh(freqIndex)		
			% keep this one
			peakTable2num = peakTable2num+1;		
			peakTable2(:,peakTable2num) = [i;freqIndex];	
			theGaussian = exp(-0.5*(([1:length(sTh)]'- freqIndex)/f_sd).^2);
			sTh = max(sTh, height*theGaussian);
		end
		whichmax = whichmax-1;
	end
	threshold2(:,i) = sTh;
	sTh = a_dec*sTh;
end
peakTable2 = fliplr(peakTable2);	% fliplr(X): Flip matrix in left/right direction. 
%threshold2 = fliplr(threshold2);
%% Pack nearby peak pairs into landmarks
lmList = zeros(peakTable2num*maxPairsPerPeak, 4);	% Each row of lmList is [t1 f1 f2 t2-t1]
nLandmark = 0;
for i =1:peakTable2num
	t1 = peakTable2(1,i);
	f1 = peakTable2(2,i);
	maxTime = t1 + timeSpan;
	minFreq = f1 - freqHalfSpan;
	maxFreq = f1 + freqHalfSpan;
	matchedIndex = find((peakTable2(1,:)>t1)&(peakTable2(1,:)<maxTime)&(peakTable2(2,:)>minFreq)&(peakTable2(2,:)<maxFreq));	% 在限定的時間範圍內  跟限定的頻率內  符合的都放到matchedIndex
	if length(matchedIndex)>maxPairsPerPeak	
		% limit the number of pairs we make; take first ones, as they will be closest in time
		matchedIndex = matchedIndex(1:maxPairsPerPeak);
	end
	for match = matchedIndex
		nLandmark = nLandmark+1;
		lmList(nLandmark,1) = t1;
		lmList(nLandmark,2) = f1;
		lmList(nLandmark,3) = peakTable2(2,match);		% f2
		lmList(nLandmark,4) = peakTable2(1,match)-t1;	% t2-t1
	end
end
lmList = lmList(1:nLandmark, :);	
% for debug return, return the pruned set of peakTable
%peakTable = peakTable2;

if showPlot
	fprintf('%s: %g sec, %d cols,  %d peakTable, %d bwd-pruned peakTable, %d lmarks\n', mfilename, duration, frameNum, peakTableNum, peakTable2num, nLandmark);
	% === Plot the spectrogram & landmarks
	imagesc(specMat); axis xy; colorbar; axis image; xlabel('Frame index'); ylabel('Freq index'); colormap gray
	line(peakTable2(1,:), peakTable2(2,:), 'color', 'k', 'marker', '.', 'linestyle', 'none');
	t1f1Prev=[];
	colorIndex=0;
	for i=1:nLandmark
		t1f1=lmList(i,1:2);
		if ~isequal(t1f1, t1f1Prev)
			lineColor=getColor(colorIndex);
			colorIndex=colorIndex+1;
			t1f1Prev=t1f1;
		end
		line(lmList(i,1)+[0, lmList(i,4)], lmList(i,2:3), 'color', lineColor); 
	end
	% === Plot the threshold & landmarks
	figure;
	subplot(211);
	imagesc(threshold1); axis xy; colorbar; axis image; xlabel('Frame index'); ylabel('Freq index'); title('Forward pass');
	for i=1:size(peakTable1,2)
		line(peakTable1(1,i), peakTable1(2,i), 'marker', '.', 'color', 'k'); 
	end
	subplot(212);
	imagesc(threshold2); axis xy; colorbar; axis image; xlabel('Frame index'); ylabel('Freq index'); title('Backward pass');
	for i=1:size(peakTable2,2)
		line(peakTable2(1,i), peakTable2(2,i), 'marker', '.', 'color', 'k'); 
	end
	colormap jet;
end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);

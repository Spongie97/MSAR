function [peakTable2, threshold2, peakTable1]=afpSpecgram2peak(specgram, afpOpt, showPlot) 
% afpSpecgram2peak: Find salient peaks from a given spectrogram
%
%	Usage:
%		peakTable = afpSpecgram2peak(specgram, afpOpt, showPlot)
%
%	Description:
%		peakTable = afpSpecgram2peak(specgram, afpOpt, showPlot)
%			specgram: a given spectrogram
%			afpOpt: options for AFP
%			showPlot: 1 for plotting
%			peakTable: a table with peaks in columns of [t, f, height]'.
%
%	Example:
%		waveFile = 'bad_romance_short.wav';
%		wObj=waveFile2obj(waveFile);
%		wObj.signal=mean(wObj.signal, 2);	% Convert to mono
%		afpOpt=afpOptSet;
%		if (wObj.fs~=afpOpt.targetFs)				
%			wObj.signal=resample(wObj.signal, afpOpt.targetFs, wObj.fs);	%  Y = RESAMPLE(X,P,Q) resamples the sequence in vector X at P/Q times the original sample rate using a polyphase implementation.  Y is P/Q times the length of X
%			wObj.fs=afpOpt.targetFs;
%		end
%		specgram=wave2specgram(wObj, afpOpt);
%		[peakTable1]=afpSpecgram2peak(specgram, afpOpt, 1);
%
%	See also afpQueryMatch, afpQueryMatchIncremental.

%	Category: Audio Fingerprinting
%	Roger Jang, 20130909

if nargin<1, selfdemo; return; end
if nargin<2; afpOpt=afpOptSet; end
if nargin<3, showPlot=0; end

%% Some parameters
maxPairsPerPeak=afpOpt.maxPairsPerPeak;	% (3) Limit the number of pairs that we'll accept from each peak
f_sd=afpOpt.f_sd;	% (30) spreading width applied to the masking skirt
a_dec = 1-0.01*(afpOpt.lmDensity/35);	% decay rate of the masking skirt behind each peak
maxPeaksPerFrame=afpOpt.maxPeaksPerFrame;	
hpf_pole=afpOpt.hpf_pole;		%  (0.98) A pole close to +1.0 results in a relatively flat high-pass filter that just removes very slowly varying parts
freqHalfSpan=afpOpt.freqHalfSpan;	% (31) +/- 50 bins in freq (LIMITED TO -32..31 IN LANDMARK2HASH)
timeSpan=afpOpt.timeSpan;  % (63) (LIMITED TO <64 IN LANDMARK2HASH)

% Take spectral features
specMat=specgram.signal;
frameNum=size(specMat,2);
mSpecMax=max(specMat(:));		
specMat=log(max(mSpecMax/1e6, specMat));		
specMat=specMat-mean(specMat(:));		% Make it zero-mean, so the start-up transients for the filter are minimized
% This is just a high pass filter, applied in the log-magnitude
% domain.  It blocks slowly-varying terms (like an AGC), but also 
% emphasizes onsets.  Placing the pole closer to the unit circle 
% (i.e. making the -.8 closer to -1) reduces the onset emphasis.
specMat = filter([1 -1], [1 -hpf_pole], specMat')';	%  High-pass filter on each freq bin. To plot the frequency response: freqz([1 -1], [1 -hpf_pole]);
maxPeakPerSec = 30;			% % Estimate for how many peakTable we keep (to preallocate array) 
duration = frameNum*afpOpt.frameShift/1000;	
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

if showPlot
	fprintf('%s: %g sec, %d cols,  %d peakTable, %d bwd-pruned peakTable\n', mfilename, duration, frameNum, peakTableNum, peakTable2num);
	% === Plot the threshold & landmarks
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
end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);
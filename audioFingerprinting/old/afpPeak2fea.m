function landmarkVec=afpPeak2fea(peakTable, specgram, afpOpt, showPlot) 
% afpPeak2fea: Pair peaks to obtain landmarks for AFP
%
%	Usage:
%		landmarkVec=afpPeak2fea(peakTable)
%		landmarkVec=afpPeak2fea(peakTable, specgram, afpOpt)
%		landmarkVec=afpPeak2fea(peakTable, specgram, afpOpt, showPlot)
%
%	Description:
%		This function returns a set of landmarks (pairs of salient peaks) from a given peak table
%		Each row of the returned landmarkVec has 4 elements [startTime startFreq endFreq deltaTime]
%		peakTable is obtained via afpSpecgram2peak.m.
%
%	Example:
%		waveFile='unchained_melody_short.wav';
%		wObj=waveFile2obj(waveFile);
%		wObj.signal=mean(wObj.signal, 2);	% Convert to mono
%		afpOpt=afpOptSet0;
%		if (wObj.fs~=afpOpt.targetFs)				
%			wObj.signal=resample(wObj.signal, afpOpt.targetFs, wObj.fs);
%			wObj.fs=afpOpt.targetFs;
%		end
%		specgram=wave2specgram(wObj, afpOpt);
%		[peakTable]=afpSpecgram2peak(specgram, afpOpt);
%		[landmarkVec]=afpPeak2fea(peakTable, specgram, afpOpt, 1);
%
%	See also afpQueryMatch, afpQueryMatchIncremental.

%	Category: Audio Fingerprinting
%	Roger Jang, 20130909

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

%% Pack nearby peak pairs into landmarks
peakNum=size(peakTable,2);
landmarkVec = zeros(peakNum*maxPairsPerPeak, 4);	% Each row of landmarkVec is [t1 f1 f2 t2-t1]
nLandmark = 0;
for i =1:peakNum
	t1 = peakTable(1,i);
	f1 = peakTable(2,i);
	maxTime = t1 + timeSpan;
	minFreq = f1 - freqHalfSpan;
	maxFreq = f1 + freqHalfSpan;
	matchedIndex = find((peakTable(1,:)>t1)&(peakTable(1,:)<maxTime)&(peakTable(2,:)>minFreq)&(peakTable(2,:)<maxFreq));	% 在限定的時間範圍內  跟限定的頻率內  符合的都放到matchedIndex
	if length(matchedIndex)>maxPairsPerPeak	
		% limit the number of pairs we make; take first ones, as they will be closest in time
		matchedIndex = matchedIndex(1:maxPairsPerPeak);
	end	
	for match = matchedIndex
		nLandmark = nLandmark+1;
		landmarkVec(nLandmark,1) = t1;
		landmarkVec(nLandmark,2) = f1;
		landmarkVec(nLandmark,3) = peakTable(2,match);		% f2
		landmarkVec(nLandmark,4) = peakTable(1,match)-t1;	% t2-t1		
	end
end
landmarkVec = landmarkVec(1:nLandmark, :);

if showPlot
	fprintf('%s: %d peaks, %d landmarks\n', mfilename,		peakNum, nLandmark);
	% === Plot the spectrogram & landmarks
	imagesc(log(specgram.signal)); axis xy; colorbar; axis image; xlabel('Frame index'); ylabel('Freq index'); colormap gray
	t1f1Prev=[];
	colorIndex=0;
	for i=1:nLandmark
		t1f1=landmarkVec(i,1:2);
		if ~isequal(t1f1, t1f1Prev)
			lineColor=getColor(colorIndex);
			colorIndex=colorIndex+1;
			t1f1Prev=t1f1;
		end
		line(landmarkVec(i,1)+[0, landmarkVec(i,4)], landmarkVec(i,2:3), 'color', lineColor);
	%	t1=landmarkVec(i,1); f1=landmarkVec(i,2); f2=landmarkVec(i,3); t2=t1+landmarkVec(i,4);
	%	boxOverlay([t1, f1-afpOpt.freqHalfSpan, afpOpt.timeSpan, 2*afpOpt.freqHalfSpan], lineColor, 1);
	end
	line(peakTable(1,:), peakTable(2,:), 'color', 'k', 'marker', '.', 'linestyle', 'none');
end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);

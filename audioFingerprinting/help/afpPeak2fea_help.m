%% afpPeak2fea
% Pair peaks to obtain landmarks for AFP
%% Syntax
% * 		landmarkVec=afpPeak2fea(peakTable)
% * 		landmarkVec=afpPeak2fea(peakTable, specgram, afpOpt)
% * 		landmarkVec=afpPeak2fea(peakTable, specgram, afpOpt, showPlot)
%% Description
%
% <html>
% <p>This function returns a set of landmarks (pairs of salient peaks) from a given peak table
% <p>Each row of the returned landmarkVec has 4 elements [startTime startFreq endFreq deltaTime]
% <p>peakTable is obtained via afpSpecgram2peak.m.
% </html>
%% Example
%%
%
waveFile='unchained_melody_short.wav';
wObj=waveFile2obj(waveFile);
wObj.signal=mean(wObj.signal, 2);	% Convert to mono
afpOpt=afpOptSet0;
if (wObj.fs~=afpOpt.targetFs)
	wObj.signal=resample(wObj.signal, afpOpt.targetFs, wObj.fs);
	wObj.fs=afpOpt.targetFs;
end
specgram=wave2specgram(wObj, afpOpt);
[peakTable]=afpSpecgram2peak(specgram, afpOpt);
[landmarkVec]=afpPeak2fea(peakTable, specgram, afpOpt, 1);
%% See Also
% <afpQueryMatch_help.html afpQueryMatch>,
% <afpQueryMatchIncremental_help.html afpQueryMatchIncremental>.

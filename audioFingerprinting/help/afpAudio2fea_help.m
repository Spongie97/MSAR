%% afpAudio2fea
% Find landmarks from a give wave object
%% Syntax
% * 		landmarkVec = afpAudio2fea(wObj)
% * 		landmarkVec = afpAudio2fea(wObj, afpOpt)
% * 		[landmarkVec, specgram] = afpAudio2fea(wObj, afpOpt)
%% Description
%
% <html>
% <p>This function returns a set of landmarks from a given wave object.
% <p>Each row of the returned landmarkVec has 4 elements [startTime startFreq endFreq deltaTime]
% </html>
%% Example
%%
%
waveFile='bad_romance_short.wav';
wObj=waveFile2obj(waveFile);
afpOpt=afpOptSet;
[landmarkVec, specgram]=afpAudio2fea(wObj, afpOpt, 1);
%% See Also
% <afpQueryMatch_help.html afpQueryMatch>,
% <afpQueryMatchIncremental_help.html afpQueryMatchIncremental>.

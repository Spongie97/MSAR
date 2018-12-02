%% afpFeaExtractForward
% Extract landmarks by forward pass only
%% Syntax
% * 		[landmarkVec, specMat_opt, threshold, peakTable, specMat] = afpFeaExtractForward(y, fs, afpOpt)
%% Description
%
% <html>
% <p>Make a set of spectral feature pair landmarks from some audio data
% <p>y is an audio waveform at sampling rate fs
% <p>landmarkVec returns as a set of landmarks, as rows of a 4-column matrix
% <p>{startTime startFreq endFreq deltaTime}
% <p>lmDensity is the target hashes-per-sec (approximately; default 5)
% <p>specMat returns the filtered log-magnitude surface
% <p>threshold returns the decaying threshold surface
% <p>peakTable returns a list of the actual time-frequency peaks extracted.
% </html>
%% Example
%%
%
waveFile = 'bad_romance_short.wav';
%[y, fs, nbits]=wavread(waveFile);
au=myAudioRead(waveFile); y=au.signal; fs=au.fs;
afpOpt=afpOptSet;
[landmarkVec, specMat, threshold, peakTable]=afpFeaExtractForward(y, fs, afpOpt, 1);
%% See Also
% <afpQueryMatchIncremental_help.html afpQueryMatchIncremental>.

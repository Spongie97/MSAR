%% landmarkFind
% Find landmarks for audio fingerprinting
%% Syntax
% * 		[landmarkVec,specMat,threshold,peakTable] = landmarkFind(y, fs, afpPrm)
%% Description
%
% <html>
% <p>Make a set of spectral feature pair landmarks from some audio data
% <p>y is an audio waveform at sampling rate fs
% <p>landmarkVec returns as a set of landmarks, as rows of a 4-column matrix
% <p>{start-time-col start-freq-row end-freq-row delta-time}
% <p>lmDensity is the target hashes-per-sec (approximately; default 5)
% <p>specMat returns the filtered log-magnitude surface
% <p>threshold returns the decaying threshold surface
% <p>peakTable returns a list of the actual time-frequency peaks extracted.
% </html>
%% Example
%%
%
waveFile = fullfile(afptRoot, 'dataset/test_corpus/The_power_of_love.wav');
[y, fs, nbits]=wavread(waveFile);
afpPrm=afpOptSet;
[landmarkVec, specMat, threshold, peakTable]=landmarkFind(y, fs, afpPrm, 1);
%% See Also
% <queryMatch_help.html queryMatch>.

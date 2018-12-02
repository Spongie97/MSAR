%% afpFeaExtract
% Extract landmarks from audio file for audio fingerprinting
%% Syntax
% * 		lmList = afpFeaExtract(y, fs)
% * 		lmList = afpFeaExtract(y, fs, afpOpt)
% * 		[lmList,specMat,threshold1,peakTable1] = afpFeaExtract(y, fs, afpOpt)
%% Description
%
% <html>
% <p>This function returns a set of landmarks (pairs of salient peaks) from audio signals y with a sampling rate fs
% <p>Each row of the returned lmList has 4 elements [startTime startFreq endFreq deltaTime], or [t1 f1 f2 t2-t1]
% <p>specMat returns the filtered log-magnitude surface
% <p>threshold1 returns the decaying threshold surface
% <p>peakTable1 returns a list of the actual time-frequency peaks extracted, with row1=frame index, row2=freq index, row3=height.
% </html>
%% Example
%%
%
waveFile = 'bad_romance_short.wav';
au=myAudioRead(waveFile); y=au.signal; fs=au.fs;
afpOpt=afpOptSet0;
[lmList, specMat, threshold1, peakTable1]=afpFeaExtract(y, fs, afpOpt, 1);
%% See Also
% <afpQueryMatch_help.html afpQueryMatch>,
% <afpQueryMatchIncremental_help.html afpQueryMatchIncremental>.

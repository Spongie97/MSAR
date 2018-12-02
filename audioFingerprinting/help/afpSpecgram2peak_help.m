%% afpSpecgram2peak
% Find salient peaks from a given spectrogram
%% Syntax
% * 		peakTable = afpSpecgram2peak(specgram, afpOpt, showPlot)
%% Description
%
% <html>
% <p>peakTable = afpSpecgram2peak(specgram, afpOpt, showPlot)
% 	<ul>
% 	<li>specgram: a given spectrogram
% 	<li>afpOpt: options for AFP
% 	<li>showPlot: 1 for plotting
% 	<li>peakTable: a table with peaks in columns of [t, f, height]'.
% 	</ul>
% </html>
%% Example
%%
%
waveFile = 'bad_romance_short.wav';
wObj=waveFile2obj(waveFile);
wObj.signal=mean(wObj.signal, 2);	% Convert to mono
afpOpt=afpOptSet;
if (wObj.fs~=afpOpt.targetFs)
	wObj.signal=resample(wObj.signal, afpOpt.targetFs, wObj.fs);	%  Y = RESAMPLE(X,P,Q) resamples the sequence in vector X at P/Q times the original sample rate using a polyphase implementation.  Y is P/Q times the length of X
	wObj.fs=afpOpt.targetFs;
end
specgram=wave2specgram(wObj, afpOpt);
[peakTable1]=afpSpecgram2peak(specgram, afpOpt, 1);
%% See Also
% <afpQueryMatch_help.html afpQueryMatch>,
% <afpQueryMatchIncremental_help.html afpQueryMatchIncremental>.

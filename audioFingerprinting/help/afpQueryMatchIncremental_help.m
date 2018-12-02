%% afpQueryMatchIncremental
% Incremental query match for AFP 
%% Syntax
% * 		[rankedResult, L] = afpQueryMatchIncremental(y, fs)
%% Description
%
% <html>
% <p>Match an audio query against the database.
% <p>Rows of rankedResult are potential matches, in format [songId, no of time-matched landmarks, startTime, all hit landmarks]
% <p>L returns the actual landmarks that this implies for IX'th return.
% </html>
%% Example
%%
%
dbFile = fullfile(afptRoot, 'dataset/database/db_10.mat');
load(dbFile);	% Load hashTable, audioData
afpOpt = afpOptSet;
waveFile=fullfile(afptRoot, 'dataset/test_corpus/The_power_of_love.wav');
%[y, fs, nbits]=wavread(waveFile);
au=myAudioRead(waveFile); y=au.signal; fs=au.fs;
f = 1;
y1 = y(1:fs*5);
y2 = y(fs*5+1:end);
[rankedResult, L, maxhits,hashVec, lmVec, opt] = afpQueryMatchIncremental(y1,fs,hashTable, afpOpt, 1, [], f);   % ���ѫe5����q
[rankedResult, L, maxhits,hashVec, lmVec] = afpQueryMatchIncremental(y2,fs,hashTable, afpOpt, 1, opt, f);   % ���ѫ�5����q
fprintf('Top-5 results\n');
for i=1:5
	fprintf('%d: %s\n', i, audioData(rankedResult(i)).mainName);
end
%% See Also
% <afpFeaExtractForward_help.html afpFeaExtractForward>.

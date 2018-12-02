%% queryMatchIncremental
% 
%% Syntax
% * 		[rankedResult, L] = queryMatchIncremental(y, fs)
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
afpPrm = afpOptSet;
waveFile=fullfile(afptRoot, 'dataset/test_corpus/The_power_of_love.wav');
[y, fs, nbits]=wavread(waveFile);
f = 1;
y1 = y(1:fs*5);
y2 = y(fs*5+1:end);
[rankedResult, L, maxhits,hashVec, lmVec, opt] = queryMatchIncremental(y1,fs,hashTable, afpPrm, 1, [], f);   % 辨識前5秒片段
[rankedResult, L, maxhits,hashVec, lmVec] = queryMatchIncremental(y2,fs,hashTable, afpPrm, 1, opt, f);   % 辨識後5秒片段
fprintf('Top-5 results\n');
for i=1:5
	fprintf('%d: %s\n', i, audioData(rankedResult(i)).mainName);
end
%% See Also
% <landmarkFindForward_help.html landmarkFindForward>.

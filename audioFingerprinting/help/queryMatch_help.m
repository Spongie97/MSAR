%% queryMatch
% 
%% Syntax
% * 		[rankedResult, L] = queryMatch(y, fs)
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
[rankedResult, L, hashVec, lmVec]=queryMatch(y, fs, hashTable);
fprintf('Top-5 results\n');
for i=1:5
	fprintf('%d: %s\n', i, audioData(rankedResult(i)).mainName);
end
%% See Also
% <landmarkFind_help.html landmarkFind>.

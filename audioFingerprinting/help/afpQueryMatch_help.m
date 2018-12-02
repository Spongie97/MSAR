%% afpQueryMatch
% Match a given query to an AFP database
%% Syntax
% * 		songList=afpQueryMatch(y, fs, hashTable)
%% Description
%
% <html>
% <p>Match an audio query against the database.
% <p>Rows of songList are potential matches, with format [songId, matched landmark count, most likely query time offset, no. of all hit landmarks]
% </html>
%% Example
%%
% Create the song database
audioDir = fullfile(afptRoot, 'dataset/music4db');
afpOpt=afpOptSet;
db=afpDbCreate(audioDir, afpOpt);
%%
% Generate 10-sec query
auFile=fullfile(afptRoot, 'dataset/music4query/The Power Of Love_xxx_noisy01.mp3');
au=myAudioRead(auFile); y=au.signal; fs=au.fs;
y=y(1:10*fs, :);	% Take the first 10 seconds for query
%%
% Match the query to the database
songList=afpQueryMatch(y, fs, db.hashTable, afpOpt);
fprintf('Top-3 results\n');
for i=1:3
	fprintf('%d: %s\n', i, db.audioData(songList(i)).mainName);
end
%% See Also
% <afpFeaExtract_help.html afpFeaExtract>.

%% Tutorial on using the Audio Fingerprinting Toolbox
% The Audio Fingerprinting Toolbox provides serveral functions to perform
% audio fingerprinting, including feature extraction, database
% construction, and performance evaluation.
%
% The following demonstrates how to find landmarks and plot the spectrogram
auFile='bad_romance_short.wav';
au=myAudioRead(auFile); y=au.signal; fs=au.fs;
afpOpt=afpOptSet0;
[lmList, specMat, threshold1, peakTable1]=afpFeaExtract(y, fs, afpOpt, 1);
%% Database construction
% To create a database for AFP: 
audioDir = fullfile(afptRoot, 'dataset/music4db');
afpOpt=afpOptSet0;
db=afpDbCreate(audioDir, afpOpt);
%%
% For each audio file, we need to create a key such that each query can be
% associated with:
for i=1:length(db.audioData)
	db.audioData(i).key=db.audioData(i).mainName;
end
%% Query corpus collection
% Then we can collect the queries for testing AFP, as follows:
queryDir = fullfile(afptRoot, 'dataset/music4query');
format = 'mp3';
queryData = recursiveFileList(queryDir, format);
fileNum = length(queryData);
fprintf('\nStart performance evaluation of %d recordings:\n', fileNum);
dbKey={db.audioData.key};
for i=1:fileNum
	index=find(queryData(i).name=='_');
	queryData(i).key=queryData(i).name(1:index(end)-1);
	queryData(i).gt=find(strcmp(queryData(i).key, dbKey));
end
%% Performance evaluation
% The query file was chopped into 10-second segments for testing AFP. Once both the query set and the database is ready, we can test the
% performance of AFP:
[overallRr, queryData]=afpPerfEval(queryData, db, afpOpt, 1);
%%
% Copyright 2012-2016 <http://mirlab.org/jang Jyh-Shing Roger Jang>.
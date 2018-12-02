%% afpPerfEval
% AFP performance evaluation
%% Syntax
% * 		[overallRr, queryData, gtData]=afpPerfEval(queryData, db, afpOpt, showPlot)
%% Description
%
% <html>
% </html>
%% Example
%%
%
audioDir = fullfile(afptRoot, 'dataset/music4db');
afpOpt=afpOptSet0;
db=afpDbCreate(audioDir, afpOpt);
% === Collect the key of the database
for i=1:length(db.audioData)
	db.audioData(i).key=db.audioData(i).mainName;
end
% === Collect the test corpus and create its groundtruth field
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
[overallRr, queryData]=afpPerfEval(queryData, db, afpOpt, 1);
%% See Also
% <afpFeaExtract_help.html afpFeaExtract>,
% <afpQueryMatch_help.html afpQueryMatch>.

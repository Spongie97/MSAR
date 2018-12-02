% This is the main program for testing the recognition rates of QBSH (query by singing/humming)
% Roger Jang, 20070529, 20130425

clear all; close all; more off

%% ====== Specify the folder for query files
auDir='/Users/spongie/Documents/MATLAB/2017-msar-pvOnly-noGt';				% 2983 pv files, top-1 RR=87.3617%
% auDir='queryInput';									% 103 pv files, top-1 RR=85.4369%
%auDir='queryInput-noGt';							% 103 pv files
%auDir='D:\dataSet\childSong\2017-msar-pvOnly-noGt';		% 2983 pv files
%auDir='D:\dataSet\childSong\2016-msar-pvOnly';		% 2392 pv files, top-1 RR=93.1438%
%% ====== Set up parameters for QBSH
qbshOpt=myQbshOptSet;				% Get the default options
%qbshOpt.method='dtw1'; qbshOpt.useRest=0;	% You can overwrite the default options here
%% ====== Read *.wav and *.pv files into auSet
myTic=tic;
auSet=qbshAuSetCreate(auDir, qbshOpt, 1);
fprintf('Time=%g sec\n', toc(myTic));
save auSet auSet	% Sav auSet.mat for easy access
%% ====== Read song database and perform database preprocessing
fprintf('Get songDb from "%s"...\n', qbshOpt.songDb);
songDb=songDbRead(qbshOpt.songDb);
for i=1:length(songDb), songDb(i).id=songDb(i).songName; end
fprintf('Generate pv from the songDb ===> '); tic;
for i=1:length(songDb),
	note = double(songDb(i).track);
	songDb(i).pv = note2pv(note, qbshOpt.ptOpt.frameRate, inf, 0);
	songDb(i).anchorPvIndex=1;
end
fprintf('%.2f seconds\n', toc);
fprintf('Handle rests ===> '); tic;
for i=1:length(songDb)
	songDb(i).pv=pvRestHandle(songDb(i).pv, qbshOpt.useRest);
end
fprintf('%.2f seconds\n', toc);
save songDb songDb	% Save songDb.mat for easy access
%% ====== Compute recog. rate
[recogRate, auSet]=qbshPerfEval(songDb, auSet, qbshOpt, 1);		% Compute recog. rate of each file
fprintf('Overall recognition rate = %.2f%%\n', 100*recogRate);
fprintf('Total search time: %g seconds\n', sum([auSet.time]));
fprintf('Average search time for a wave file: %g seconds\n', mean([auSet.time]));
%% ====== Plot figures
rankPlot([auSet.rank]);
figure; singerSet=qbshPersonRr(auSet, 1);		% Compute the recog. rate for each person
%qbshFileList(auSet);		% List the files accoring to ranking
%% ====== Write result file. You need to upload the result file!
for i=1:length(auSet)
	[~, index]=min(auSet(i).dist);
	auSet(i).result=sprintf('%s\t%s', auSet(i).path, songDb(index).songName);
end
result={auSet.result};
[~, mainName]=fileparts(auDir);
resultFile=sprintf('output/Result_%s.txt', mainName);
fprintf('Saving %s...\n', resultFile);
fileWrite(result, resultFile);
%% ====== Accuracy based on the result file
contents=textread(resultFile, '%s', 'delimiter', '\n', 'whitespace', '');
for i=1:length(contents)
	items=split(contents{i}, 9);
	filePath=items{1};
	pSongName=items{2};
	[parentDir, mainName]=fileparts(filePath);
	index=find(mainName=='_');		% twinkle twinkle little star_unknown_0.pv.wav
	tSongName=mainName(1:index(2)-1);	% songName='twinkle twinkle little star_unknown';
	correct(i)=isequal(lower(tSongName), lower(pSongName));
end
fprintf('Top-1 RR=%g%%\n', sum(correct)/length(correct)*100);



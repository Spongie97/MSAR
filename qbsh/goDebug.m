load auSet.mat
load songDb.mat
waveFile='waveFile/19461108_kevin/虎姑婆_不詳_0.wav';
%waveFile='waveFile/9665812_yifen/小星星_不詳_0.wav';
waveFile='waveFile/9665812_yifen/兩隻老虎_不詳_0.wav';
waveIndex=find(strcmp(waveFile, {auSet.path}));
queryPitch=auSet(waveIndex).tPitch;
allSongIds={songDb.id};

qbshOpt=myQbshOptSet;
[dist, minIndex] = feval(qbshOpt.matchFcn, songDb, queryPitch, qbshOpt);	% 將 query pitch 比對所有的歌
[minDist, retrievedSongIndex]=min(dist);
gdSongId=auSet(waveIndex).songId;		% 找出所有和標準答案同名的歌曲
gdSongIndex=find(strcmp(gdSongId, allSongIds));
fprintf('waveFile=%s\n', waveFile);
fprintf('gdSong=%s, gdSongIndex=%d\n', auSet(waveIndex).songId, gdSongIndex);
fprintf('Retrieved song=%s, retrievedSongIndex=%d\n', songDb(retrievedSongIndex).songName, retrievedSongIndex);
[sortedDist, sortIndex]=sort(dist);
temp=allSongIds(sortIndex);
rank=find(strcmp(gdSongId, temp));
fprintf('Rank of gdSong: %d\n', rank);

%% Comparison with the GD song
% Align with the retrieved song
dbPitch=songDb(retrievedSongIndex).pv;
dbPitchLen=min(length(dbPitch), round(qbshOpt.upperRatio*length(queryPitch)));
dbPitch=dbPitch(1:dbPitchLen);
[minDist, scaledPitch, allDist]=linScaling4qbsh(queryPitch, dbPitch, qbshOpt, 1);
% Align with the GD song
dbPitch=songDb(gdSongIndex).pv;
dbPitchLen=min(length(dbPitch), round(qbshOpt.upperRatio*length(queryPitch)));
dbPitch=dbPitch(1:dbPitchLen);
figure; [minDist, scaledPitch, allDist]=linScaling4qbsh(queryPitch, dbPitch, qbshOpt, 1);

wObj=waveFile2obj(waveFile);
pitchObj1.signal=queryPitch;
pitchObj1.frameRate=8000/(qbshOpt.ptOpt.frameSize-qbshOpt.ptOpt.overlap);
pitchObj1.buttonLabel='Original pitch';
pitchObj2.signal=dbPitch;
pitchObj2.frameRate=8000/(qbshOpt.ptOpt.frameSize-qbshOpt.ptOpt.overlap);
pitchObj2.buttonLabel='DB pitch';
buttonH=wavePitchPlayButton(wObj, pitchObj1, pitchObj2);

fprintf('Hit any key to hear the GD database song...'); pause; fprintf('\n');
notePlay(songDb(gdSongIndex).track(1:20), 1/64, 1, 1);
fprintf('Hit any key to hear the retrieved database song...'); pause; fprintf('\n');
notePlay(songDb(retrievedSongIndex).track(1:20), 1/64, 1, 1);
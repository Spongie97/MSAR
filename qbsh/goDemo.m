% This is the main program to demo QBSH (query by singing/humming)
% Roger Jang, 20130918

clear all; more off
%% ====== Display song list
dos('start midi\index.htm');
%% ====== Set up parameters for QBSH
qbshOpt=myQbshOptSet;				% Get the default options
%qbshOpt.method='dtw1'; qbshOpt.useRest=0;	% You can assign new options here
%% ====== Read song database and perform database preprocessing
fprintf('Get songDb from "%s"...\n', qbshOpt.songDb);
songDb=songDbRead(qbshOpt.songDb);
for i=1:length(songDb), songDb(i).id=songDb(i).songName; end
fprintf('Generate pv from the songDb ===> '); tic;
for i=1:length(songDb),
	note = double(songDb(i).track);
	songDb(i).pv = note2pv(note, qbshOpt.ptOpt.frameSize, inf, 0);
	songDb(i).anchorPvIndex=1;
end
fprintf('%.2f seconds\n', toc);
fprintf('Handle rests ===> '); tic;
for i=1:length(songDb)
	songDb(i).pv=pvRestHandle(songDb(i).pv, qbshOpt.useRest);
end
fprintf('%.2f seconds\n', toc);
%% ====== Start recording and test
fs=8000;		% Sampling rate (取樣頻率)
nbits=8;
duration=8;		% Recording duration (錄音時間)
while 1
    % === Recording
	fprintf('Press any key to start %g seconds of recording...', duration); pause
	fprintf('Recording...');
	y=wavrecord(duration*fs, fs, 'uint8');	% duration*fs is the total number of sample points
	fprintf('Finished recording.\n');
	waveFile=[tempname, '.wav'];
%	fprintf('Saving %s\n', waveFile);
	wavwrite(y, fs, nbits, waveFile);
%	fprintf('Press any key to play %s...\n', waveFile); pause
%	dos(['start ', waveFile]);	% Start the application for .wav file (開啟與 wav 檔案對應的應用程式)
	% === Pitch Tracking
    fprintf('Performing pitch tracking...\n');
	wObj=waveFile2obj(waveFile);
	pitch=pitchTracking(wObj, qbshOpt.ptOpt, 1);
	% === Start retrieving
	fprintf('Start retriving songs...\n');
	[distance, minIndex] = feval(qbshOpt.matchFcn, songDb, pitch, qbshOpt);	% 將一首wave比對所有的歌
	[sortedDistance, sortIndex]=sort(distance);
	fprintf('Result:\n');
	for i=1:10
		fprintf('\t%d: songName=<a href="matlab: dos(''start /b %s'');">%s</a>, distance=%.3f\n', i, songDb(sortIndex(i)).midiName, songDb(sortIndex(i)).songName, sortedDistance(i));
    end
    fprintf('\n');
end
%% ====== Compute recog. rate
[recogRate, auSet]=qbshPerfEval(songDb, auSet, qbshOpt, 1);		% Compute recog. rate of each file
fprintf('Overall recognition rate = %.2f%%\n', 100*recogRate);
fprintf('Total search time: %g seconds\n', sum([auSet.time]));
fprintf('Average search time for a wave file: %g seconds\n', mean([auSet.time]));
%% ====== Plot figures
rankPlot([auSet.rank]);
qbshPersonRr(auSet);		% Compute the recog. rate for each person
qbshFileList(auSet);		% List the files accoring to ranking
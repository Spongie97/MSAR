% This program demonstrates how to play songs in the database in either MIDI or PV formats.
% 此程式展示如何播放標準答案的歌曲

%% ====== Play note sequence
songDb=songDbRead('childSongEnglish');
i=42;
noteNum=20;
%fprintf('按鍵後播放 "%s" 的前 %d 個音符 ...\n', songDb(i).midiName, noteNum); pause
fprintf('Hit return to play the first %d notes of %s...\n', noteNum, songDb(i).midiName); pause
note=songDb(i).track(1:noteNum*2);
notePlay(note, 1/64);
%% ====== Play PV
%fprintf('按鍵後播放轉成 pv 格式的音樂資料 ...\n'); pause
frameRate=8000/256;
fprintf('Hit return to play the song in PV format...\n'); pause
%pv = note2pv(note, frameRate, 9, [], 1);
pv=asciiRead('twinkle_twinkle_little_star.pv');
method=2;
pvPlay(pv, frameRate, method);
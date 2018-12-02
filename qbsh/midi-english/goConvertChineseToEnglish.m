% You need to copy "midi" to "midi-english", and run this program with "midi-english" to convert Chinese file names to English.

mappingFile='songTitleMapping.txt';
table=tableRead(mappingFile, 1, {'english', 'chinese'});
englishSongTitle={table.english};
chineseSongTitle={table.chinese};

midiSet=dir('*.mid');
for i=1:length(midiSet)
	file01=midiSet(i).name;
	items=split(file01, '_'); theChineseSongTitle=items{1};
	index=find(strcmp(theChineseSongTitle, chineseSongTitle));
	if length(index)==1
		theEnglishSongTitle=englishSongTitle{index};
	else
		theEnglishSongTitle=theChineseSongTitle;
	end
	file02=[theEnglishSongTitle, '_unknown.mid'];
	if ~isequal(file01, file02)
		fprintf('%d/%d: file01=%s, file02=%s\n', i, length(midiSet), file01, file02);
		movefile(file01, file02);
	end
end

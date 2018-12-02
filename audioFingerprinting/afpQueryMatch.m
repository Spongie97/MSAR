function songList=afpQueryMatch(y, fs, hashTable, afpOpt)
% afpQueryMatch: Match a given query to an AFP database
%
%	Usage:
%		songList=afpQueryMatch(y, fs, hashTable)
%
%	Description:
%		Match an audio query against the database.
%		Rows of songList are potential matches, with format [songId, matched landmark count, most likely query time offset, no. of all hit landmarks]
%
%	Example:
%		% === Create the song database
%		audioDir = fullfile(afptRoot, 'dataset/music4db');
%		afpOpt=afpOptSet;
%		db=afpDbCreate(audioDir, afpOpt);
%		% === Generate 10-sec query
%		auFile=fullfile(afptRoot, 'dataset/music4query/The Power Of Love_xxx_noisy01.mp3');
%		au=myAudioRead(auFile); y=au.signal; fs=au.fs;
%		y=y(1:10*fs, :);	% Take the first 10 seconds for query
%		% === Match the query to the database
%		songList=afpQueryMatch(y, fs, db.hashTable, afpOpt);
%		fprintf('Top-3 results\n');
%		for i=1:3
%			fprintf('%d: %s\n', i, db.audioData(songList(i)).mainName);
%		end
%
%	See also afpFeaExtract.

%	Category: Audio Fingerprinting
%	Roger Jang, 20130716, 20160205

if nargin<1, selfdemo; return; end
if nargin<4, afpOpt=afpOptSet; end

%% Resample if necessary
y=mean(y,2);	% Convert y to a mono row-vector
if (fs~=afpOpt.targetFs)				
	y=resample(y, afpOpt.targetFs, fs);	%  Y = RESAMPLE(X,P,Q) resamples the sequence in vector X at P/Q times the original sample rate using a polyphase implementation.  Y is P/Q times the length of X
	fs=afpOpt.targetFs;
%	idx = floor(fs/afpOpt.targetFs);	% take one point for each five points (assume original sample rate is 44100 Hz)
%	y = y(1:idx:end);
end

lmList = afpFeaExtract(y, fs, afpOpt);		% lmList: landmark vec, with each row = [t1 f1 f2 t2-t1]
hopSize = round(afpOpt.frameShift*fs/1000);
for i=1:afpOpt.queryRepeatCount-1	% Augment with landmarks calculated with small advancement
	lmList = [lmList; afpFeaExtract(y(round(i/afpOpt.queryRepeatCount*hopSize):end), fs, afpOpt)];
end
hashList=afpFea2hash(lmList, [], afpOpt);
hashList=unique(hashList, 'rows');		%  Row format: [hashKey, t1]
hitList=afpHashHitGet(hashList, hashTable, afpOpt);	% Row format: [songId, qTimeOffset, hashKey, lmStartTimeInDb, lmStartTimeInQuery]
if isempty(hitList), songList=[]; return; end

uSongId=unique(hitList(:,1));		% uSongId=unique song id
songList=zeros(length(uSongId), 4);	% Row format: [songId, matched LM count, mostLikelyQTimeOffset, no. all hit landmarks]
for i=1:length(uSongId)
	hitListOfSong = hitList(hitList(:,1)==uSongId(i), :);	% find the data witnin hitList(:,1) for a given song
	mostLikelyQTimeOffset=mode(hitListOfSong(:,2));		% 該首歌出現最多次的 qTimeOffset (query time offset)
	matchedLmCount=sum(abs(hitListOfSong(:,2)-mostLikelyQTimeOffset)<=afpOpt.timeTolerance);
	songList(i,:) = [uSongId(i), matchedLmCount, mostLikelyQTimeOffset, size(hitListOfSong,1)];
end

% Sort by descending matched LM count
[~ , index]=sort(songList(:,2), 'descend');
songList=songList(index,:);

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);

function [rankedResult, L, maxhits,hashVec, lmVec] = afpQueryMatch(y, fs, hashTable, eight_times, afpOpt, IX)
%	Usage:
%		[rankedResult, L] = afpQueryMatch(y, fs, hashTable)
%
%	Description:
%		Match an audio query against the database.
%		Rows of rankedResult are potential matches, in format [songId, no of time-matched landmarks, startTime, all hit landmarks]
%		L returns the actual landmarks that this implies for IX'th return.
%
%	Example:
%		% === Create the song database
%		audioDir = fullfile(afptRoot, 'dataset/music4db');
%		afpOpt=afpOptSet;
%		db=afpDbCreate(audioDir, afpOpt);
%		% === Generate 10-sec query
%		waveFile=fullfile(afptRoot, 'dataset/music4query/The Power Of Love_xxx_noisy01.wav');
%		au=myAudioRead(waveFile); y=au.signal; fs=au.fs;
%		y=y(1:10*fs, :);	% Take 10 seconds for query
%		% === Match the query to the database
%		[rankedResult, L, hashVec, lmVec]=afpQueryMatch(y, fs, db.hashTable, 0, afpOpt);
%		fprintf('Top-3 results\n');
%		for i=1:3
%			fprintf('%d: %s\n', i, db.audioData(rankedResult(i)).mainName);
%		end
%
%	See also afpFeaExtract.

%	Category: Audio Fingerprinting
%	Roger Jang, Pei-Yu Liao, 20130716

if nargin<1, selfdemo; return; end
if nargin<4, eight_times = 0; end
if nargin<5, afpOpt=afpOptSet; end
if nargin<6, IX = 1; end

%% Resample if necessary
y=mean(y,2);	% Convert y to a mono row-vector
if (fs~=afpOpt.targetFs)				
	y=resample(y, afpOpt.targetFs, fs);	%  Y = RESAMPLE(X,P,Q) resamples the sequence in vector X at P/Q times the original sample rate using a polyphase implementation.  Y is P/Q times the length of X
	fs=afpOpt.targetFs;
%	idx = floor(fs/afpOpt.targetFs);	% take one point for each five points (assume original sample rate is 44100 Hz)
%	y = y(1:idx:end);
end

lmVec = afpFeaExtract(y, fs, afpOpt);		% lmVec: landmark vec, with each row = [t1 f1 f2 t2-t1]

% Augment with landmarks calculated half-a-window advanced too
hopSize = afpOpt.frameShift/1000*fs;
if eight_times
	times = 8;
else
	times = 4;
end
for i=1:times-1
	lmVec = [lmVec; afpFeaExtract(y(round(i/times*hopSize):end), fs, afpOpt)];
end
hashVec=afpFea2hash(lmVec, 0, afpOpt);
hashVec = unique(hashVec, 'rows');		%  Row format: [0, t1, hashKey]
hitList = afpHashHitGet(hashVec, hashTable, afpOpt);	% Row format: [songId, qTimeOffset, hashKey, lmStartTimeInDb, lmStartTimeInQuery]
if isempty(hitList), rankedResult = []; return; end

[uTrackId, uTrackCount]=elementCount(hitList(:,1), 'count');		% uTrackId=unique track id, uTrackCount=歌曲重複的次數（依此由大到小）
uTrackNum = length(uTrackId);									

rankedResult = zeros(uTrackNum, 4);	% Row format: [songId, matched LM count, mostLikelyQTimeOffset, no. all hit landmarks]
for i = 1:uTrackNum	
	hitListOfSong = hitList(hitList(:,1)==uTrackId(i), :);			% find the data witnin hitList(:,1) for a given track
%	[qTimeOffsetUniq, qTimeOffsetCount]=elementCount(hitListOfSong(:,2), 'count');	% Find the most likely qTimeOffset for a given track
%	mostLikelyQTimeOffset=qTimeOffsetUniq(1);		% 該首歌出現最多次的 qTimeOffset (query time offset)
	mostLikelyQTimeOffset=mode(hitListOfSong(:,2));
	matchedLmCount=sum(abs(hitListOfSong(:,2)-mostLikelyQTimeOffset)<=afpOpt.timeTolerance);
	rankedResult(i,:) = [uTrackId(i), matchedLmCount, mostLikelyQTimeOffset, size(hitListOfSong,1)];	% 找和hitListOfSong(:,2)最接近的值，塞進rankedResult (hitListOfSong(:,2)該首歌的dtimes)
end

% Sort by descending matched LM count
[~ , index] = sort(rankedResult(:,2), 'descend');
rankedResult = rankedResult(index,:);						

% Extract the actual landmarks
H = hitList((hitList(:,1)==rankedResult(IX,1)) & (hitList(:,2)==rankedResult(IX,3)),:);	
%H = hitList((hitList(:,1)==rankedResult(IX,1)) & (abs(hitList(:,2)-rankedResult(IX,3))<=1),:);	% 偏移的frame個數允許誤差在一個frame內
%
% Restore the original times
for i = 1:size(H,1)
	hix = find(hashVec(:,3)==H(i,3));
	hix = hix(1);  % if more than one...
	H(i,2) = H(i,2)+hashVec(hix,2);
	L(i,:) = afpHash2fea(H(i,:));
end
% Return no more than 100 hits, and only down to 10% the #hits in
% most popular
maxrtns = 100;
if size(rankedResult,1) > maxrtns	
	rankedResult = rankedResult(1:maxrtns,:);
end
maxhits = rankedResult(1,2);
nuffhits = rankedResult(:,2)>(0.1*maxhits);

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);

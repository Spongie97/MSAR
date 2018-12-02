function [rankedResult, L, maxhits,hashVec, lmVec,info_1to5] = afpQueryMatchIncremental(y, fs, hashTable, afpOpt, IX, opt,frameNum)
% afpQueryMatchIncremental: Incremental query match for AFP 
%
%	Usage:
%		[rankedResult, L] = afpQueryMatchIncremental(y, fs)
%
%	Description:
%		Match an audio query against the database.
%		Rows of rankedResult are potential matches, in format [songId, no of time-matched landmarks, startTime, all hit landmarks]
%		L returns the actual landmarks that this implies for IX'th return.
%
%	Example:
%		dbFile = fullfile(afptRoot, 'dataset/database/db_10.mat'); 
%		load(dbFile);	% Load hashTable, audioData
%		afpOpt = afpOptSet;
%		waveFile=fullfile(afptRoot, 'dataset/test_corpus/The_power_of_love.wav');
%		%[y, fs, nbits]=wavread(waveFile);
%		au=myAudioRead(waveFile); y=au.signal; fs=au.fs;
%		f = 1; 
%		y1 = y(1:fs*5);
%		y2 = y(fs*5+1:end);
%		[rankedResult, L, maxhits,hashVec, lmVec, opt] = afpQueryMatchIncremental(y1,fs,hashTable, afpOpt, 1, [], f);   % 辨識前5秒片段
%		[rankedResult, L, maxhits,hashVec, lmVec] = afpQueryMatchIncremental(y2,fs,hashTable, afpOpt, 1, opt, f);   % 辨識後5秒片段
%		fprintf('Top-5 results\n');
%		for i=1:5
%			fprintf('%d: %s\n', i, audioData(rankedResult(i)).mainName);
%		end
%
%	See also afpFeaExtractForward.
%
%
%	Category: Incremental Query
%	Pei-Yu Liao, 20130716

if nargin<1, selfdemo; return; end
if nargin<4, afpOpt=afpOptSet; end
if nargin<5, IX = 1; end
if nargin<6, opt=[]; end
if nargin<7, frameNum = 1; end


%  ===== from find_lm =====
y=mean(y,2);	% Convert y to a mono row-vector
if (fs~=afpOpt.targetFs)
	y=resample(y, afpOpt.targetFs, fs);	%  Y = RESAMPLE(X,P,Q) resamples the sequence in vector X at P/Q times the original sample rate using a polyphase implementation.  Y is P/Q times the length of X
	fs=afpOpt.targetFs;
%	idx = floor(fs/afpOpt.targetFs);
%	y = y(1:idx:end);
end

offset = floor((8820*5-512)/(1024-512)); % 計算前五秒的frame個數 ===> (x - 512) / 512 = offset ;  fft時計算過的frame
fft_diff = 8820*5-44032; % 44032 = offset * 512 + 512 ;  FFT時計算過的sample點與原本五秒的sample點之差距


% Augment with landmarks calculated half-a-window advanced too
hopSize = 0.064*fs;		

if isempty(opt)   
	% ===== 1~5 sec =====
	[lmVec_1to5, specMat_all, threshold_all] = afpFeaExtractForward(y, fs, afpOpt);		% lmVec: landmark vec, with each row = [t1 f1 f2 t2-t1]
	[lmVec_1to5_1, specMat_1, threshold_1] = afpFeaExtractForward(y(round(1/4*hopSize):end), fs, afpOpt);
	[lmVec_1to5_2, specMat_2, threshold_2] = afpFeaExtractForward(y(round(2/4*hopSize):end), fs, afpOpt);
	[lmVec_1to5_3, specMat_3, threshold_3] = afpFeaExtractForward(y(round(3/4*hopSize):end), fs, afpOpt);
	lmVec = [lmVec_1to5; lmVec_1to5_1; lmVec_1to5_2; lmVec_1to5_3];
	info_1to5.y = y;
	info_1to5.lmVec_1to5 = lmVec;
	info_1to5.specMat_all = specMat_all;
	info_1to5.specMat_1 = specMat_1;
	info_1to5.specMat_2 = specMat_2;
	info_1to5.specMat_3 = specMat_3;
	info_1to5.threshold_all = threshold_all;
	info_1to5.threshold_1 = threshold_1;
	info_1to5.threshold_2 = threshold_2;
	info_1to5.threshold_3 = threshold_3;
else
	% ===== 6~10 sec =====
	overlap_y = opt.y(8820*5-fft_diff-(512*frameNum)+1:end); % 扣除FFT的差距及往前overlap (frameNum-1)個frame
	y = [overlap_y; y]; % 結合overlap前段的y及後五秒的y
	lmVec_6to10 = afpFeaExtractForward(y, fs, afpOpt, 0, opt.threshold_all(:, end),opt.specMat_all);		% lmVec: landmark vec, with each row = [t1 f1 f2 t2-t1]
	lmVec_6to10 = [lmVec_6to10; afpFeaExtractForward(y(round(1/4*hopSize):end), fs, afpOpt, 0, opt.threshold_1(:, end),opt.specMat_1)];
	lmVec_6to10 = [lmVec_6to10; afpFeaExtractForward(y(round(2/4*hopSize):end), fs, afpOpt, 0, opt.threshold_2(:, end),opt.specMat_2)];
	lmVec_6to10 = [lmVec_6to10; afpFeaExtractForward(y(round(3/4*hopSize):end), fs, afpOpt, 0, opt.threshold_3(:, end),opt.specMat_3)];
	lmVec_6to10(:,1) = lmVec_6to10(:,1) + offset - frameNum+1; %將6~10秒的t1加上前五秒的frame個數-向前的overlap frame個數 (但因frameNum=1時實際上是沒有overlap，所以再+1回來)
	lmVec = [opt.lmVec_1to5; lmVec_6to10];
end

hashVec = unique(afpFea2hash(lmVec), 'rows'); %  Row of hashVec: [0, t1, hashKey]

hitList = afpHashHitGet(hashVec, hashTable);	

if isempty(hitList)
	rankedResult = [];
	return;
end

[uTracks, uTrackCount]=elementCount(hitList(:,1), 'count');		
uTracksNum = length(uTracks);									


rankedResult = zeros(uTracksNum, 4);	% Row format: [songId, no. of time-matched landmarks, qTimeOffset, no. all hit landmarks]
for i = 1:uTracksNum	
	hitListOfSong = hitList(hitList(:,1)==uTracks(i),:);			% find the data witnin hitList(:,1) for a given track
	[qTimeOffsetUniq, qTimeOffsetCount]=elementCount(hitListOfSong(:,2), 'count');	% Find the most likely qTimeOffset given a track
	mostLikelyQTimeOffset=qTimeOffsetUniq(1);		
	rankedResult(i,:) = [uTracks(i), sum(abs(hitListOfSong(:,2)-mostLikelyQTimeOffset)<=1), mostLikelyQTimeOffset, size(hitListOfSong,1)];	% 找和hitListOfSong(:,2)最接近的值，塞進rankedResult (hitListOfSong(:,2)該首歌的dtimes)
end

% Sort by descending match count
[~ , index] = sort(rankedResult(:,2), 'descend');
rankedResult = rankedResult(index,:);						

%5 18 1 18 means tks{5} was matched with 18 matching landmarks, at a
% time skew of 1 frame (query starts ~ 0.032s after beginning of
% reference track), and a total of 18 hashes matched that track at
% any time skew (meaning that in this case all the matching hashes
% had the same time skew of 1).

% Extract the actual landmarks
H = hitList((hitList(:,1)==rankedResult(IX,1)) & (hitList(:,2)==rankedResult(IX,3)),:);	
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

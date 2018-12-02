function hitList = afpHashHitGet(hashList, hashTable, afpOpt)
%afpHashHitGet: Return hash values in a hash table given a set of given landmarks
%
%	Usage:
%		hitList = afpHashHitGet(hashList, hashTable, afpOpt)
%
%	Description:
%		Return hit list from song hash table for a given particular hashes
%		Row of hashList = [hashKey, t1]
%		Row of hitList = [songId, qTimeOffset, hashKey, lmStartTimeInDb, lmStartTimeInQuery]
%
%	Example:
%		audioDir = fullfile(afptRoot, 'dataset/music4db');
%		afpOpt=afpOptSet;
%		db=afpDbCreate(audioDir, afpOpt);
%		afpOpt = afpOptSet;
%		auFile=fullfile(afptRoot, 'dataset/music4query/The Power Of Love_xxx_noisy01.mp3');
%		au=myAudioRead(auFile); y=au.signal; fs=au.fs;	
%		y=mean(y,2);		
%		lmList = afpFeaExtract(y, fs, afpOpt);		% lmList: each row = [t1 f1 f2 t2-t1]
% 		%Augment with landmarks calculated half-a-window advanced too
%		hopSize = 0.064*fs;		
%		lmList = [lmList; afpFeaExtract(y(round(1/4*hopSize):end), fs, afpOpt)];
%		lmList = [lmList; afpFeaExtract(y(round(2/4*hopSize):end), fs, afpOpt)];
%		lmList = [lmList; afpFeaExtract(y(round(3/4*hopSize):end), fs, afpOpt)];
%		hashList = unique(afpFea2hash(lmList), 'rows');	%  Row of hashList: [0, t1, hashKey]
%		hitList = afpHashHitGet(hashList, db.hashTable);
%		disp(hitList);
%
%	Category:Audio Fingerprinting
%	Roger Jang, 20130903, 20160205

if nargin<1, selfdemo; return; end
if nargin<4, afpOpt=afpOptSet; end

hashKeys=hashList(:,1);		% hashKey
outputCount=sum(hashTable.count(hashKeys+1));	% Total count of retrieved hash values
hitList = zeros(outputCount, 5);	% Pre-allocation
hitListLen=0;
for i=1:length(hashKeys)
	lmStartTimeInQuery = double(hashList(i,2));	% landmark start time in query
	nEntry = hashTable.count(hashKeys(i)+1);	% No. of matched entries for each query hash
	htCol = double(hashTable.table{hashKeys(i)+1})';	% Hit hash values
	songId = floor(htCol/afpOpt.timeSize);	% Extract songId from htCol
	lmStartTimeInDb = round(htCol-songId*afpOpt.timeSize);	% Extract lmStartTimeInDb from htCol
	qTimeOffset = lmStartTimeInDb-lmStartTimeInQuery;	
%	hitList(hitListLen+[1:nEntry], :) = [songId, qTimeOffset, repmat(double(hashKeys(i)), nEntry,1)];		% Original
	hitList(hitListLen+[1:nEntry], :) = [songId, qTimeOffset, repmat(double(hashKeys(i)), nEntry,1), lmStartTimeInDb, repmat(double(lmStartTimeInQuery), nEntry,1)];	% For Cookie's experiments
	hitListLen=hitListLen+nEntry;
end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);
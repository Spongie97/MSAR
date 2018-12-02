function hitList = afpHashHitGet(hashVec, hashTable, afpOpt)
%afpHashHitGet:
%
%	Usage:
%		hitList = afpHashHitGet(hashVec, hashTable, afpOpt)
%
%	Description:
%		Return hit list from song hash table for a given particular hashes
%		Row of hashVec = [0, t1, hashKey]
%		Row of hitList = [songId, qTimeOffset, hashKey]
%
%	Example:
%		audioDir = fullfile(afptRoot, 'dataset/music4db');
%		afpOpt=afpOptSet;
%		db=afpDbCreate(audioDir, afpOpt);
%		afpOpt = afpOptSet;
%		waveFile=fullfile(afptRoot, 'dataset/music4query/The Power Of Love_xxx_noisy01.wav');
%		%[y, fs, nbits]=wavread(waveFile);
%		au=myAudioRead(waveFile); y=au.signal; fs=au.fs;	
%		y=mean(y,2);		
%		lmVec = afpFeaExtract(y, fs, afpOpt);		% lmVec: landmark vec, with each row = [t1 f1 f2 t2-t1]
% 		%Augment with landmarks calculated half-a-window advanced too
%		hopSize = 0.064*fs;		
%		lmVec = [lmVec; afpFeaExtract(y(round(1/4*hopSize):end), fs, afpOpt)];
%		lmVec = [lmVec; afpFeaExtract(y(round(2/4*hopSize):end), fs, afpOpt)];
%		lmVec = [lmVec; afpFeaExtract(y(round(3/4*hopSize):end), fs, afpOpt)];
%		hashVec = unique(afpFea2hash(lmVec), 'rows');	%  Row of hashVec: [0, t1, hashKey]
%		hitList = afpHashHitGet(hashVec, hashTable);
%		disp(hitList);
%
%	Category:Audio Fingerprinting
%	Roger Jang, 20130903

if nargin<1, selfdemo; return; end
if nargin<4, afpOpt=afpOptSet; end

if size(hashVec,2)==3, hashVec=hashVec(:,[2 3]); end	

hashKeys=hashVec(:,2);
outputCount=sum(hashTable.count(hashKeys+1));
%hitList = zeros(outputCount, 3);
hitList = zeros(outputCount, 5);
hitListLen=0;
for i=1:size(hashVec,1)
	lmStartTimeInQuery = double(hashVec(i,1));	% landmark start time in query
	nEntry = hashTable.count(hashKeys(i)+1);		
%	if nEntry>0	% This if-then statement is unnecessary!
		htCol = double(hashTable.table{hashKeys(i)+1})';	
		songId = floor(htCol/afpOpt.timeSize);			
		lmStartTimeInDb = round(htCol-songId*afpOpt.timeSize);
		qTimeOffset = lmStartTimeInDb-lmStartTimeInQuery;	
%		hitList(hitListLen+[1:nEntry], :) = [songId, qTimeOffset, repmat(double(hashKeys(i)), nEntry,1)];
        hitList(hitListLen+[1:nEntry], :) = [songId, qTimeOffset, repmat(double(hashKeys(i)), nEntry,1),lmStartTimeInDb,repmat(double(lmStartTimeInQuery), nEntry,1)];	% Modified by Cookie

%	end
	hitListLen=hitListLen+nEntry;
end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);
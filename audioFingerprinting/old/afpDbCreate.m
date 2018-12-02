function [db, time]=afpDbCreate(audioDir, afpOpt)
% afpDbCreate: Create a database for AFP from a given audio directory
%
%	Usage:
%		db=afpDbCreate(audioDir, afpOpt)
%
%	Description:
%		Create the database file according to the give directory of audio files.
%
%	Example:
%		audioDir = fullfile(afptRoot, 'dataset/music4db');
%		afpOpt=afpOptSet;
%		db=afpDbCreate(audioDir, afpOpt);

%	Category:Audio Fingerprinting
%	Roger Jang, 20130731, 20160205

if nargin<1, selfdemo; return; end
if nargin<2, afpOpt=afpOptSet; end

scriptTic=tic;
% ====== Collect mp3 and wav files
audioData=[recursiveFileList(audioDir, 'mp3'); recursiveFileList(audioDir, 'wav')];
fprintf('Collected %d files from %s for constructing the database...\n', length(audioData), audioDir);

% ====== Create hash table
hashTable.table = cell(1, afpOpt.keyNum);
hashTable.count = zeros(1, afpOpt.keyNum);

for i=1:length(audioData)
	myTic=tic;
	[~, audioData(i).mainName]=fileparts(audioData(i).path);
	fprintf('%d/%d: file=%s ===> ', i, length(audioData), audioData(i).path);
	audioData(i).readingError=0;
	try
		au=myAudioRead(audioData(i).path); y=au.signal; fs=au.fs;
	catch
		fprintf('\tSomething wrong when reading %s.\n', audioData(i).path);
		audioData(i).readingError=1;
		continue;
	end
	lmList=afpFeaExtract(y, fs, afpOpt);	% Each row of lmList is [t1 f1 f2 t2-t1]
	hashList=afpFea2hash(lmList, i, afpOpt);	% Row of hashList = [songId t1 hashKey]
	if any(hashList(:,2)>=afpOpt.timeSize)	% Error checking
		fprintf('Warning: timeOffSet is larger than its maximum!\n');
	end
	hashKey=hashList(:,3)+1;		% Convert to MATLAB indexing
	hashValue=i*afpOpt.timeSize+hashList(:,2);
	% === Add to the hash table
	for j=1:size(hashList,1)
		id=hashKey(j);
		hashTable.count(id)=hashTable.count(id)+1;
		hashTable.table{id}(hashTable.count(id))=uint32(hashValue(j));
	end
	audioData(i).hashCount=size(hashList,1);
	audioData(i).duration=length(y)/fs;
	audioData(i).time=toc(myTic);
	fprintf('hashCount=%d, clip duration=%g sec, computing time=%g sec\n', audioData(i).hashCount, audioData(i).duration, audioData(i).time);
end
db.audioDir=audioDir;
db.audioData=audioData;
db.hashTable=hashTable;
time=toc(scriptTic);
fprintf('Total hash count = %d, total clip duration = %g sec, no. of invalid songs = %d\n', sum([audioData.hashCount]), sum([audioData.duration]), sum([audioData.readingError])); 
fprintf('Total time for database creation: %f seconds\n', time);

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);
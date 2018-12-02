function afpDbAppend(oldDbPath, newAudioDir, newDbFileName)
% afpDbAppend: Append new entries in a databse for AFP
%
%	Usage:
%		afpDbAppend(oldDbPath, newAudioDir, newDbFileName)
%
%	Description:
%		Accoriding to your given old database path and new audio file directory, 
%		this toolbox will add songs to the new database and output the dbFile 
%		with your new dbFileName.
%
%	Example:
%		addpath(fullfile(afptRoot, 'mp3_toolbox/'));
%		oldDbPath = fullfile(afptRoot, 'dataset/database/db_10.mat');
%		newAudioDir = fullfile(afptRoot,'dataset/mp3/');
%		newDbFileName = 'new_testDb';
%		afpDbAppend(oldDbPath, newAudioDir, newDbFileName);

%	Category:Audio Fingerprinting
%	Pei-Yu Liao, 20130731

if nargin<1, selfdemo; return; end
if nargin<2, newAudioDir = fullfile(afptRoot,'dataset/mp3/'); end
if nargin<3, newDbFileName = 'new_testDb'; end

addpath(fullfile(afptRoot, 'mp3_toolbox/'));

load(oldDbPath);	% load old database

current_songNum = length(audioData);

newAudioData = [recursiveFileList(newAudioDir, 'mp3'); recursiveFileList(newAudioDir, 'wav')];
fprintf('Collected %d files for adding songs to database...\n', length(newAudioData));
afpOpt=afpOptSet;

for i=1:length(newAudioData)
	myTic=tic;
	[parentDir, newAudioData(i).mainName, extName]=fileparts(newAudioData(i).path);
	fprintf('%d/%d: file=%s ===> ', i, length(newAudioData), newAudioData(i).path);
	newAudioData(i).readingError=0;
	try
	%	if strcmpi(extName, '.mp3'), [y, fs] = mp3read(newAudioData(i).path); end
	%	if strcmpi(extName, '.wav'), [y, fs] = wavread(newAudioData(i).path); end
		au=myAudioRead(newAudioData(i).path); y=au.signal; fs=au.fs;
	catch
		fprintf('\tSomething wrong when reading %s.\n', newAudioData(i).path);
		newAudioData(i).readingError=1;
		continue;
	end
	hashVec = afpFea2hash(afpFeaExtract(y, fs, afpOpt));	% Row of hashVec = [songId t1 hashKey]
	% === Add to the hash table
	for j=1:size(hashVec,1)
		toffs = mod(round(hashVec(j,2)), afpOpt.timeSize);	% Is this necessary???
		hashKey = 1+hashVec(j,3);			% avoid problems with hashKey == 0
		hashTable.count(hashKey) = hashTable.count(hashKey)+1;
		if isempty(hashTable.table{hashKey})
			hashTable.table{hashKey} =uint32((i+current_songNum)*afpOpt.timeSize + toffs);
		else
			hashTable.table{hashKey} = [hashTable.table{hashKey} uint32((i+current_songNum)*afpOpt.timeSize + toffs)];
		end
	end
	newAudioData(i).hashCount=size(hashVec,1);
	newAudioData(i).duration=length(y)/fs;
	newAudioData(i).time=toc(myTic);
	fprintf('hashCount=%d, clip duration=%g sec, computing time=%g sec\n', newAudioData(i).hashCount, newAudioData(i).duration, newAudioData(i).time);
end

audioData(current_songNum+1:current_songNum+length(newAudioData)) = newAudioData;

fprintf('Total hash count = %d, total clip duration = %g sec, no. of invalid songs = %d\n', sum([newAudioData.hashCount]), sum([newAudioData.duration]), sum([newAudioData.readingError])); 
newDbFileName = sprintf('%s.mat', newDbFileName);
save(newDbFileName,'hashTable', 'audioData');
fprintf('Total computing time: %f hours\n', sum([newAudioData.time])/3600);

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);

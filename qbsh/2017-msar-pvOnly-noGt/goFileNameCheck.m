% Check the main name of the recordings
% Roger Jang, 20170515

% addpath d:/users/jang/matlab/toolbox/utility

dirName='./';
pvSet=recursiveFileList(dirName, 'pv');
wavSet=recursiveFileList(dirName, 'wav');
theSet=[pvSet; wavSet];
%% Check main file names
for i=1:length(theSet)
	[~, theSet(i).mainName]=fileparts(theSet(i).name);
	if strcmp(theSet(i).mainName,'hictory dictory dock_unknown_0 (1)')
		fprintf('%d \n', i);
	end
end
uniqueMainName=unique({theSet.mainName});
file='uniqueMainName.txt';
fprintf('Writing %s...\n', file);
fileWrite(uniqueMainName, file);
%edit(file);
%% Check if wav without pv
fprintf('Check if wav without pv...\n');
for i=1:length(wavSet)
	wavFile=wavSet(i).path;
	pvFile=[wavFile(1:end-3), 'pv'];
	if ~exist(pvFile, 'file')
		fprintf('%s not exist!\n', pvFile);
	end
end
%% Check if pv without wav
fprintf('Check if pv without wav...\n');
for i=1:length(pvSet)
	pvFile=pvSet(i).path;
	wavFile=[pvFile(1:end-2), 'wav'];
	if ~exist(wavFile, 'file')
		fprintf('%s not exist!\n', wavFile);
	end
end

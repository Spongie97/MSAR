function auSet=ptAuSetRead(auDir);
% ptAuSetRead: Read all audio files and their pv (pitch vector) files from a given audio directory.
%
%	Usage:
%		auSet=ptAuSetRead(auDir)
%
%	Description:
%		auSet=ptAuSetRead(auDir) returns a structure array containing data from the audio files within a given audio directory
%			auSet(i).errorTag=0 ==> No error
%			auSet(i).errorTag=1 ==> NO groundtruth pv files
%			auSet(i).errorTag=2 ==> Groundtruth pitch are all zeros
%
%	Example:
%		auDir='waveFile';
%		auSet=ptAuSetRead(auDir);
%		disp(auSet);

%	Roger Jang, 20030509, 20130411

if nargin<1, selfdemo; return; end

temp=recursiveFileList(auDir, 'wav');
auNum=length(temp);
if auNum==0, auSet=[]; return; end

for i=1:auNum
	auSet(i)=myAudioRead(temp(i).path);
end

% ====== Attach more fields
for i=1:auNum
%	fprintf('%d/%d ===> %s\n', i, auNum, temp(i).path);
	auSet(i).singer=temp(i).parentDir;		% Get speaker information
	[parentDir, auSet(i).mainName]=fileparts(auSet(i).file);
	index=find(auSet(i).mainName=='_');
	auSet(i).songName=auSet(i).mainName(1:index(2)-1);
	auSet(i).errorTag=0;	% No error
	pitchFile=[auSet(i).file(1:end-3), 'pv'];
	if exist(pitchFile)~=2
	%	fprintf('Cannot find the pitchFile = %s\n', pitchFile);
		auSet(i).pitch=[];
		auSet(i).errorTag=1;	% Tag=1 ==> No GT pitch file
	else
		fid=fopen(pitchFile, 'r');
		auSet(i).pitch=fscanf(fid, '%f', inf);
		fclose(fid);
	end
end

% 列出沒有對應 pitch 檔案的 wave 檔案
%if ~isempty(errorIndex)
%	fprintf('\nList of .wav files with no corresponding .pv files:\n');
%	for i=1:length(errorIndex)
%		fprintf('%d/%d: %s\n', i, length(errorIndex), auSet(errorIndex(i)).path);
%	end
%	auSet(errorIndex)=[];
%end

% 如果抓到的 pitch 都是零...
for i=1:length(auSet)
	if ~isempty(auSet(i).pitch) & sum(abs(auSet(i).pitch))==0
		auSet(i).errorTag=2;	% Tag=1 ==> GT pitch is all zeros
	end
end
%if ~isempty(errorIndex)
%	fprintf('\nList of .wav files with all-zero pitch:\n');
%	for i=1:length(errorIndex)
%		fprintf('%d/%d: %s\n', i, length(errorIndex), auSet(errorIndex(i)).path);
%	end
%	auSet(errorIndex)=[];
%end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);
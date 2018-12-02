function ptFileCheck(auSet, singer, mode)
% ptFileCheck: Check each file after PT using myPt.m
%
%	Usage:
%		ptFileCheck(auSet)
%		ptFileCheck(auSet, singer)
%		ptFileCheck(auSet, singer, mode)
%
%	Description:
%		ptFileCheck(auSet): check each audio (from the badly performed ones) in auSet by displaying its pitch
%			auSet: a structure array of an audio set (See the following example as how to obtain the array)
%		ptFileCheck(auSet, singer): check the audio of a specific singer
%		ptFileCheck(auSet, singer, mode): check the audio of a specific singer using a specific mode
%			mode=0 ==> using myPt.m with showPlot=1
%			mode=1 ==> using the pitch labeling program (which allows the display of the frame and several PDFs)
%
%	Example:
%		auDir='waveFile';
%		fprintf('Reading audio files from %s...\n', auDir);
%		auSet=ptAuSetRead(auDir);
%		ptOpt=myPtOptSet;
%		[recogRate, auSet2]=ptPerfEval(auSet, ptOpt);
%		ptFileCheck(auSet2, 'all', 1);

%	Roger Jang, 20150409

if nargin<1; selfdemo; return; end
if nargin<2, singer='all'; end
if nargin<3, mode=1; end

% ====== Take the data from a specific singer
if nargin>1 && ~strcmp(singer, 'all')
	auSet=auSet(strcmp(singer, {auSet.singer}));
	if isempty(auSet), error('Cannot find files from the given singer %s!', singer); end
end
if isempty(auSet), error('Given auSet is empty!'); end

rr=[auSet.rr];		% Collect the recognition rate of each file
[junk, index]=sort(rr);
for i=1:length(index)
	fprintf('%d/%d: %s ===> %.2f%%\n', i, length(index), auSet(index(i)).file, 100*auSet(index(i)).rr);
	au=myAudioRead(auSet(index(i)).file);
	switch mode
		case 0
			opt=myPtOptSet;
			myPt(au, opt, 1);
			fprintf('\tPress any key to continue...\n'); pause
		case 1
			ptOpt=ptOptSet(au.fs, au.nbits);
			ptOpt.waveFile=au.file;
			ptOpt.targetPitchFile=[ptOpt.waveFile(1:end-3), 'pv'];
			ptOpt.frameSize=round(32*au.fs/1000);
			ptOpt.overlap=0;
			ptOpt.useVolThreshold=0;
			ptOpt.frame2pitchFcn='frame2pitch4labeling';
			pitchLabel(au, ptOpt);
			h=findobj(0, 'string', 'Save pitch'); delete(h);	% "Save pitch" is not allowed
			fprintf('\tPress any key to continue...\n'); pause
			close all;
		otherwise
			error('Unknown mode in ptFileCheck()!');
	end
end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);
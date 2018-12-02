function ptPersonRr(auSet)
% ptPersonRr: List of RR of each person
%
%	Usage:
%		ptPersonRr(auSet)
%
%	Example:
%		auDir='waveFile';
%		fprintf('Reading audio files from %s...\n', auDir);
%		auSet=ptAuSetRead(auDir);
%		ptOpt=myPtOptSet;
%		[recogRate, auSet2]=ptPerfEval(auSet, ptOpt);
%		ptPersonRr(auSet2);

%	Roger Jang, 20150328

if nargin<1, selfdemo; return; end

allSinger={auSet.singer};
uniqSinger=unique(allSinger);
for i=1:length(uniqSinger)
	singerSet(i).name=uniqSinger{i};
	index=find(strcmp(allSinger, singerSet(i).name));
	singerSet(i).songCount=length(index);
%	singerSet(i).rr=sum([auSet(index).rr])/length(index);
	singerSet(i).rr=sum([auSet(index).correctCount])/sum([auSet(index).allCount]);
end
[junk, index]=sort([singerSet.rr], 'descend');
singerSet=singerSet(index);
rrPlot(singerSet)

fprintf('Recognition rate of each person:\n');
for i=1:length(singerSet)
	fprintf('%s: song count=%d, recog. rate=%.2f%%\n', singerSet(i).name, singerSet(i).songCount, 100*singerSet(i).rr);
end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);
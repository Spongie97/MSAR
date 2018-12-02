function [recogRate, auSet, time]=ptPerfEval(auSet, ptOpt)
% ptPerfEval: PT (pitch tracking) performance evaluation
%
%	Usage:
%		[recogRate, auSet, time]=ptPerfEval(auSet)
%		[recogRate, auSet, time]=ptPerfEval(auSet, ptOpt)
%
%	Description:
%		recogRate=ptPerfEval(auSet) returns the recognition rate of myPt over the given auSet
%		See the following example.
%
%	Example:
%		auDir='waveFile';
%		fprintf('Reading audio files from %s...\n', auDir);
%		auSet=ptAuSetRead(auDir);
%		ptOpt=myPtOptSet;
%		[recogRate, auSet2, time]=ptPerfEval(auSet, ptOpt);
%		fprintf('Overall recognition rate = %.2f%%.\n', recogRate*100);
%		fprintf('Time = %g sec\n', time);

%	Roger Jang, 20150328

if nargin<1, selfdemo; return; end
if nargin<2, ptOpt=myPtOptSet; end

% ====== Pitch tracking for each file
myTic=tic;
auNum=length(auSet);
for i=1:auNum
	fprintf('%d/%d: %s\n', i, auNum, auSet(i).file);
	thisTic=tic;
	auSet(i).computedPitch=myPt(auSet(i), ptOpt);
	computedPitch=auSet(i).computedPitch(:);
	desiredPitch=auSet(i).pitch(:);
	index=find(desiredPitch>0);		% We are interested in "raw pitch accuracy"!
	auSet(i).correctCount=sum(abs(computedPitch(index)-desiredPitch(index))<0.5);
	auSet(i).allCount=length(index);
	auSet(i).rr=auSet(i).correctCount/auSet(i).allCount;
	auSet(i).time=toc(thisTic);
	fprintf('\tTime=%g sec, recog. rate = %.2f%%\n', auSet(i).time, auSet(i).rr*100);
end

% ====== Overall recognition rate
recogRate=sum([auSet.correctCount])/sum([auSet.allCount]);
time=toc(myTic);

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);

% This is an example of parameter tuning for QBSH
% Roger Jang, 20130426

%% ====== Data loading
load auSet.mat
load songDb.mat
%% ====== Set up parameters for melody recognition (mr)
qbshOpt=myQbshOptSet;				% Get the default options
%qbshOpt.method='dtw1'; qbshOpt.useRest=0;	% You can assign new options here
%% ====== Compute recog. rate
resolution=11:5:51;
recogRate=zeros(1, length(resolution));
time=zeros(1, length(resolution));
for i=1:length(resolution)
	qbshOpt.resolution=resolution(i);
	[recogRate(i), auSet]=qbshPerfEval(songDb, auSet, qbshOpt);		% Compute recog. rate of each file
	time(i)=mean(([auSet.time]));
	fprintf('%d/%d: resolution=%d, rr=%g%%\n', i, length(resolution), resolution(i), recogRate(i)*100);
end
plot(time, recogRate*100, 'o-');
xlabel('Time for each query (sec)');
ylabel('Recog. rate (%)');
title('Recog. rate vs. computing time (with varying resolutions)');
for i=1:length(resolution)
	h=text(time(i), recogRate(i)*100, [' Resolution = ', int2str(resolution(i))]);
	set(h, 'rot', 270);
end

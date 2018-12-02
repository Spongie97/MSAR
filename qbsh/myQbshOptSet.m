function qbshOpt=qbshOptSet
% qbshOptSet: Set up options for QBSH
%	Usage: qbshOpt=qbshOptSet

%	Roger Jang, 20130425

%% ====== Add necessary toolboxes
addpath /Users/spongie/Downloads/MathWorks/R2017a/archives/utility
addpath /Users/spongie/Downloads/MathWorks/R2017a/archives/sap
addpath /Users/spongie/Downloads/MathWorks/R2017a/archives/sap/mex	% For using linScaling2Mex.mex*
addpath /Users/spongie/Downloads/MathWorks/R2017a/archives/machineLearning
%% ====== Fixed options
qbshOpt.songDb='childSongEnglish';
qbshOpt.anchorPos='songStart';		% 'songStart', 'sentenceStart', or 'noteStart' [����m]
qbshOpt.matchFcn='myQbsh';		% Function for matching the query pitch
qbshOpt.matchType='wave2midi';		% Match type: wave against midi
qbshOpt.usePv=1;			% Use human-labeled pitch vector instead of doing pitch tracking on wave files
switch(qbshOpt.usePv)
	case 1
		qbshOpt.ptOpt.frameRate=31.25;		% For PV
	case 0
		qbshOpt.ptOpt=ptOptSet(8000, 8);	% For pitch tracking
	otherwise
		error('Unknown option qbshOpt.usePv=ds\n', qbshOpt.usePv);
end
%% ====== Modifiable options
qbshOpt.method='ls';		% Match method ('ls' for linear scaling, 'dtw1' for type-1 dtw, 'dtw2' for type-2 dtw), used in myQbsh.m [����k�A�Ш� myQbsh.m]
%% ====== Options for each specific method
switch(qbshOpt.method)
	case {'ls'}	% LS options
		qbshOpt.lowerRatio=0.5;
		qbshOpt.upperRatio=2.0;
		qbshOpt.resolution=51;		% Resolution of LS [�u�ʦ��Y������]
		qbshOpt.lsDistanceType=1;
		qbshOpt.useRest=1;		% Use rest (1: extend previous nonzero note, 0: delete rest) [�O�_�ϥΥ��š]1�G�ϥΫe�@�ӫD�s���ŨӨ�N�A0�G�屼���š^]
	case {'dtw1', 'dtw2'} % DTW options
		qbshOpt.beginCorner=1;		% Anchored beginning [�Y�T�w]
		qbshOpt.endCorner=0;		% Free end [���B��]
		qbshOpt.dtwCount=5;		% No of key transposition [�C�����ݶi��X�� DTW]
		qbshOpt.useRest=0;		% Use rest (1: extend previous nonzero note, 0: delete rest) [�O�_�ϥΥ��š]1�G�ϥΫe�@�ӫD�s���ŨӨ�N�A0�G�屼���š^]
	otherwise
		error('Unknown option qbshOpt.method=%s\n', qbshOpt.method);
end

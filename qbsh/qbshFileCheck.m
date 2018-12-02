function qbshFileCheck(auSet, singer)
% qbshFileCheck: Check each file after QBSH
%
%	Usage:
%		qbshFileCheck(auSet)
%		qbshFileCheck(auSet, singer)
%
%	Description:
%		auSet can be obtained after running goTest.m

% ====== Take the data from a specific singer
if nargin>1
	auSet=auSet(strcmp(singer, {auSet.singer}));
	if isempty(auSet), error('Cannot find files from the given singer %s!', singer); end
end
if isempty(auSet), error('Given auSet is empty!'); end

qbshOpt=qbshOptSet;					% Get the default parameters

rank=[auSet.rank];
[junk, index]=sort(rank, 'descend');
for i=1:length(index);
	waveFile=auSet(index(i)).path;
%	[y, fs, nbits] = wavread(waveFile);
	[cPitch, clarity]=pitchTrack(waveFile, qbshOpt.ptOpt, 1);	
	fprintf('Hit return to continue...'); pause; fprintf('\n');
end
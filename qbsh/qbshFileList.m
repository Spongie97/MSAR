function qbshFileList(auSet, singer)
% qbshFileList: List each file in badWave.htm after QBSH
%
%	Usage:
%		qbshFileList(auSet)
%		qbshFileList(auSet, singer)
%
%	Description:
%		auSet can be obtained after running goTest.m

% ====== Take the data from a specific singer
if nargin>1
	auSet=auSet(strcmp(singer, {auSet.singer}));
	if isempty(auSet), error('Cannot find files from the given singer %s!', singer); end
end
if isempty(auSet), error('Given auSet is empty!'); end
outputHtmlFile=[tempname, '.html'];

rank=[auSet.rank];
[junk, index]=sort(rank, 'descend');
fid=fopen(outputHtmlFile, 'w');
fprintf(fid, '<ol>\n');
for i=1:length(index);
	wavPath=auSet(index(i)).path;
	pvPath=[wavPath(1:end-3), 'pv'];
	fprintf(fid, '<li> rank=%g<br>Wave: <a href="%s">%s</a><br>Pitch: <a href="%s">%s</a>\r\n', auSet(index(i)).rank, wavPath, wavPath, pvPath, pvPath);
end
fprintf(fid, '</ol>\n');
fclose(fid);
fprintf('Write list of ranked wave files to "%s".\n', outputHtmlFile);
dos(['start ', outputHtmlFile]);
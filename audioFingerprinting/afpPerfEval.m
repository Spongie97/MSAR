function [overallRr, queryData, gtData]=afpPerfEval(queryData, db, afpOpt, showPlot)
%afpPerfEval: AFP performance evaluation
%
%	Usage:
%		[overallRr, queryData, gtData]=afpPerfEval(queryData, db, afpOpt, showPlot)
%
%	Example:
%		audioDir = fullfile(afptRoot, 'dataset/music4db');
%		afpOpt=afpOptSet;
%		db=afpDbCreate(audioDir, afpOpt);
%		% === Collect the key of the database
%		for i=1:length(db.audioData)
%			db.audioData(i).key=db.audioData(i).mainName;
%		end
%		% === Collect the test corpus and create its groundtruth field
%		queryDir = fullfile(afptRoot, 'dataset/music4query');
%		format = 'mp3';
%		queryData = recursiveFileList(queryDir, format);
%		fileNum = length(queryData);
%		fprintf('\nStart performance evaluation of %d recordings:\n', fileNum);
%		dbKey={db.audioData.key};
%		for i=1:fileNum
%			index=find(queryData(i).name=='_');
%			queryData(i).key=queryData(i).name(1:index(end)-1);
%			queryData(i).gt=find(strcmp(queryData(i).key, dbKey));
%		end
%		[overallRr, queryData]=afpPerfEval(queryData, db, afpOpt, 1);
%
%	See also afpFeaExtract, afpQueryMatch.

%	Category: Audio Fingerprinting
%	Roger Jang, 20130816, 20140501

if nargin<1, selfdemo; return; end
if nargin<4, showPlot=0; end

theTic=tic;
fileNum=length(queryData);
for i=1:fileNum
	fprintf('%d/%d: file=%s\n', i, fileNum, queryData(i).name);
	au=myAudioRead(queryData(i).path);
	% === Chop into small query segments if necessary
	queryLen=afpOpt.queryLength*au.fs;
	hopLen=afpOpt.queryHopLength*au.fs;
	queryNum=floor((size(au.signal, 1)-queryLen+hopLen)/hopLen);
	for j=1:queryNum
		fprintf('\t%d/%d: ', j, queryNum);
		ticInLoop=tic;
		songList=afpQueryMatch(au.signal((j-1)*hopLen+(1:queryLen), :), au.fs, db.hashTable, afpOpt);
		queryData(i).query(j).predicted=[];
		if ~isempty(songList)
			queryData(i).query(j).predicted=songList(1,1);
		end
		queryData(i).query(j).correct=(queryData(i).gt==queryData(i).query(j).predicted);
		queryData(i).query(j).time=toc(ticInLoop);
		fprintf('time=%g sec, predicted=%d (%s)\n', queryData(i).query(j).time, queryData(i).query(j).predicted, db.audioData(queryData(i).query(j).predicted).key);
	end
end
% ====== Compute overall accuracy
query=[queryData.query];
overallRr=sum([query.correct])/length(query);
% ====== Compute break-down accuracy
uniqGt=unique([queryData.gt]);
for i=1:length(uniqGt)
	gtData(i).gt=uniqGt(i);
	index=(uniqGt(i)==[queryData.gt]);
	theQuery=[queryData(index).query];
	gtData(i).rr=sum([theQuery.correct])/length(theQuery);
	gtData(i).queryCount=length(theQuery);
end

if showPlot
	fprintf('Overall recognition rate: %g%%\n', 100*overallRr);
	fprintf('Total running time: %f sec\n', toc(theTic));
	fprintf('Average retrieval time per query: %f sec\n', mean([query.time]));
	% ====== Compute break-down accuracy
	for i=1:length(uniqGt)
		fprintf('%d/%d: Song name = %s, queryClipCount=%d, accuracy=%g%%\n', i, length(uniqGt), db.audioData(uniqGt(i)).name, gtData(i).queryCount, 100*gtData(i).rr);
	end
end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);
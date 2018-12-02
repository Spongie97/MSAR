function [rr, queryCount]=afpAccuracy(resultFile, gtFile)
% Compute the recognition rate based on gtFile and resultFile

if nargin<1, resultFile='result.txt'; end
if nargin<2, gtFile='../query/query_5692/groundTruth.txt'; end

%fprintf('Reading %s...\n', resultFile);
query2predicted=tableRead(resultFile, 1, {'query', 'predicted', 'time'});
queryCount=length(query2predicted);
%fprintf('Reading %s...\n', gtFile);
query2gt=tableRead(gtFile, 1, {'query', 'gt'});

allQuery={query2gt.query};
for i=1:queryCount
	query2predicted(i).noGt=0;
	index=find(strcmp(query2predicted(i).query, allQuery));
	if length(index)==1
		query2predicted(i).gt=query2gt(index).gt;
	else
		query2predicted(i).noGt=1;
	end
end
%fprintf('No. of queries with no GT: %d\n', sum([query2predicted.noGt]));
noGtIndex=find([query2predicted.noGt]);
query2predicted(noGtIndex)=[];
correctCount=sum(strcmp({query2predicted.predicted}, {query2predicted.gt}));
rr=correctCount/length(query2predicted);
%fprintf('RR=%d/%d=%g%%\n', correctCount, length(query2predicted), rr*100);
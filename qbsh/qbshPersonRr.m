function singerSet=qbshPersonRr(auSet, showPlot)
% qbshPersonRr: List of RR of each person
%
%	Usage:
%		singerSet=qbshPersonRr(auSet, showPlot)

if nargin<2, showPlot=0; end

allSinger={auSet.singer};
uniqSinger=unique(allSinger);
singerNum=length(uniqSinger);
for i=1:singerNum
	singerSet(i).singer=uniqSinger{i};
	index=find(strcmp(allSinger, singerSet(i).singer));
	rank=[auSet(index).rank];
	singerSet(i).songCount=length(index);
	if any(isnan(rank))
		singerSet(i).rr=nan;
	else
		singerSet(i).rr=sum(rank==1)/length(rank);
	end
end
fprintf('Recognition rate of each person:\n');
[junk, index]=sort([singerSet.rr]);
singerSet=singerSet(index);

if showPlot
	for i=1:length(singerSet)
		fprintf('%d/%d: %s ==> song count=%d, recog. rate=%.2f%%\n', i, length(singerSet), singerSet(i).singer, singerSet(i).songCount, 100*singerSet(i).rr);
	end
	sIndex=1:singerNum;
	subplot(211); stem(sIndex, 100*[singerSet.rr]);
	%xlabel('Years');
	ylabel('Recognition rate (%)');
	title('Recognition rate for each person');
%	legend('CS', 'Undergraduates', 'location', 'northOutside', 'orientation', 'horizontal');
	set(gca, 'xtick', sIndex);
	set(gca, 'xlim', [min(sIndex)-1, max(sIndex)+1]);
	xTickLabelRename(strPurify({singerSet.singer}));
	xTickLabelRotate(300, 8, 'left');
end
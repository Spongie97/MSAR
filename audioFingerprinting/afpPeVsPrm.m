function [pe, elapsedTime]=afpPeVsPrm(queryDir, opt, showPlot)
%afpPeVsPrm: AFP performance evaluation versus parameter using executable files
%
%	Usage:
%		pe=afpPeVsPrm(queryDir, opt, showPlot)
%
%	Description:
%		pe=afpPeVsPrm(queryDir, opt) returns AFP performance evaluation result
%
%	Example:
%		queryDir='../query/query_10';
%		opt=afpPeVsPrm('defaultOpt');
%		showPlot=1;
%		pe=afpPeVsPrm(queryDir, opt, showPlot);
%
%	See afpAccuracy.

%	Category: AFP performance evaluation
%	Roger Jang, 20160123

if nargin<1, selfdemo; return; end
if ischar(queryDir) && strcmpi(queryDir, 'defaultOpt')	% Set the default options
	pe.prmName='maxPeaksPerFrame';
	pe.prmVec=10:2:20;
	pe.dbDir='../db/Mirex_10000_database/lm_4times';
	return
end
if nargin<2||isempty(opt), opt=feval(mfilename, 'defaultOpt'); end
if nargin<3, showPlot=0; end

scriptTic=tic;
prmCount=length(opt.prmVec);
resultFile='result.txt';
gtFile=sprintf('%s/groundTruth.txt', queryDir);
for i=1:prmCount
	thePrm=opt.prmVec(i);
	fprintf('%d/%d: %s=%d\n', i, prmCount, opt.prmName, thePrm);
	afpPrmFile=tempname;	% Why this does not work on Kelly's computer?
	afpPrmFile='afp.prm';
	fprintf('\tCreating %s as afp.prm file...\n', afpPrmFile);
	sedCmd=sprintf('sed "s/.*%s.*/%s=%d/" ../lib/afp.prm > %s', opt.prmName, opt.prmName, thePrm, afpPrmFile);
	[status, sedCmdOut]=dos(sedCmd);
	fprintf('\tRunning performance evaluation...\n');
	peCmd=sprintf('GPU.exe %s %s %s', opt.dbDir, queryDir, afpPrmFile);
	myTic=tic;
	[status, peCmdOut]=system(peCmd);
	[rr, queryCount]=afpAccuracy(resultFile, gtFile);
	time=toc(myTic);
	fprintf('\trr=%d/%d=%g%%, time=%g/%d=% gsec\n', round(rr*queryCount), queryCount, rr*100, time, queryCount, time/queryCount);
	% Record the result
	pe(i).prm=thePrm;
	pe(i).rr=rr;
	pe(i).time=time/queryCount;
end
elapsedTime=toc(scriptTic);
%% Plot the result
if showPlot
	[hAx,hLine1,hLine2] = plotyy([pe.prm], [pe.rr]*100, [pe.prm], [pe.time]);
	xlabel(opt.prmName); title(sprintf('Perf. vs. %s (queryDir=%s, time=%g sec)', opt.prmName, strPurify(queryDir), elapsedTime));
	ylabel(hAx(1), 'Accuracy (%)');			% left y-axis
	ylabel(hAx(2), 'Time per query (sec)');	% right y-axis
	set([hLine1, hLine2], 'marker', 'o');
	grid on
end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);
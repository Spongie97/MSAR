function L = afpHash2fea(H, afpOpt)
% afpHash2fea:
%
%	Usage:
%		landmarkVec=afpHash2fea(hashVec)
%
%	Description:
%		Convert a set of <time hashValue> pairs ready from store 
%		into a set of 4-entry landmarks <t1 f1 f2 dt>.
%		If H is 3 cols, first col (song ID) is discarded.
%
%
%	Example:
%		hashVec = [0 2 5507096; 0 2 5508138; 0 2 5536702; 0 3 7993729; 0 3 7963030];
%		landmarkVec = afpHash2fea(hashVec);
%		disp(landmarkVec);
%
%
%	Category:Audio Fingerprinting
%	Roger Jang, Pei-Yu Liao, 20130716
% 2008-12-29 Dan Ellis dpwe@ee.columbia.edu

if nargin<1, selfdemo; return; end
if nargin<2, afpOpt=afpOptSet; end

if size(H,2) == 3	
	H = H(:,[2 3]);
end

H1 = H(:,1);	% start
H2 = double(H(:,2));	% hash value
F1 = round(H2/(2^(afpOpt.bitNum4df+afpOpt.bitNum4dt)));	% Hash value is 24 bits: 9 bits of F1, 8 bits of F2-F1, 7 bits of delta-T，除以2^15可得到前面2^8 (F1)
H2 = H2 - (2^(afpOpt.bitNum4df+afpOpt.bitNum4dt))*F1;
F1 = F1 + 1;	
DF = floor(H2/(2^afpOpt.bitNum4dt)); 
H2 = H2 - (2^afpOpt.bitNum4dt)*DF;

if DF > 2^(afpOpt.bitNum4df-1)
	DF = DF-2^afpOpt.bitNum4df;
end
F2 = F1+DF;
DT = H2;
L = [H1,F1,F2,DT];

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);

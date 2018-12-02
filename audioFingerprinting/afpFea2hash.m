function hashList=afpFea2hash(lmList, songId, afpOpt)
% afpFea2hash: Convert landmarks to hash entries for storing
%
%	Usage:
%		hashList=afpFea2hash(lmList, songId, afpOpt)
%
%	Description:
%		hashList = afpFea2hash(lmList, songId)
%			Convert a list of 4-entry landmarks [t1 f1 f2 dt] into a list of [hashKey t1 songId] (when creating a database) or [hashKey, t1] (when query the database).
%			Each row of hashList is [hashKey t1 songId] (when songId is non-empty) or [hashKey t1] (when songId is empty).
%			songId is a scalar for landmarks (When querying the database, songId is set to a empty matrix.)
%			Hash key is 24 bits: 9 bits of f1, 8 bits of df, 7 bits of dt
%			Hash value is then determined by songId and t1.
%
%	Example:
%		lmList=[2 169 185 24; 2 169 193 42; 2 169 160 62; 3 244 231 1; 3 244 247 22];
%		songId=9;
%		hashList=afpFea2hash(lmList, songId);
%		disp(hashList);
%
%	Category:Audio Fingerprinting
%	Roger Jang, 20130716, 20160206

if nargin<1, selfdemo; return; end
if nargin<2, songId=[]; end
if nargin<3; afpOpt=afpOptSet; end

t1 = uint32(lmList(:,1));		% "-1" is missing here!		
f1 = mod(lmList(:,2)-1, 2^afpOpt.bitNum4f1);	
df = mod(lmList(:,3)-lmList(:,2), 2^afpOpt.bitNum4df);	% To keep df non-negative, you need to use "mod". ("rem" returns negative value when the given input is negative.)		
dt = mod(lmList(:,4), 2^afpOpt.bitNum4dt);	
hashKey = uint32(f1*(2^(afpOpt.bitNum4df+afpOpt.bitNum4dt))+df*(2^afpOpt.bitNum4dt)+dt);
if length(songId)==1, songId=repmat(songId, size(lmList,1), 1); end
hashList = [hashKey, t1, songId];	% This will be a 2-column matrix if the given songId is empty.

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);

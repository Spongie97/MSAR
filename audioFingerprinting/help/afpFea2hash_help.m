%% afpFea2hash
% Convert landmarks to hash entries for storing
%% Syntax
% * 		hashList=afpFea2hash(lmList, songId, afpOpt)
%% Description
%
% <html>
% <p>hashList = afpFea2hash(lmList, songId)
% 	<ul>
% 	<li>Convert a list of 4-entry landmarks [t1 f1 f2 dt] into a list of [hashKey t1 songId] (when creating a database) or [hashKey, t1] (when query the database).
% 	<li>Each row of hashList is [hashKey t1 songId] (when songId is non-empty) or [hashKey t1] (when songId is empty).
% 	<li>songId is a scalar for landmarks (When querying the database, songId is set to a empty matrix.)
% 	<li>Hash key is 24 bits: 9 bits of f1, 8 bits of df, 7 bits of dt
% 	<li>Hash value is then determined by songId and t1.
% 	</ul>
% </html>
%% Example
%%
%
lmList=[2 169 185 24; 2 169 193 42; 2 169 160 62; 3 244 231 1; 3 244 247 22];
songId=9;
hashList=afpFea2hash(lmList, songId);
disp(hashList);

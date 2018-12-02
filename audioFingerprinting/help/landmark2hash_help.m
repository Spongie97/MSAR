%% landmark2hash
% Convert landmarks to hash entries for storing
%% Syntax
% * 		hashVec=landmark2hash(landmarkVec, songId)
%% Description
%
% <html>
% <p>hashVec = landmark2hash(landmarkVec, songId)
% 	<ul>
% 	<li>Convert a set of 4-entry landmarks [t1 f1 f2 dt] into a set of [songId t1 hashKey] triples ready to store.
% 	<li>Row of hashVec = [songId t1 hashKey]
% 	<li>songId is a scalar songid, or one per landmark (defaults to 0)
% 	<li>Hash index is 24 bits: 9 bits of f1, 8 bits of df, 7 bits of dt
% 	</ul>
% </html>
%% Example
%%
%
landmarkVec=[2 169 185 24; 2 169 193 42; 2 169 160 62; 3 244 231 1; 3 244 247 22];
songId=9;
hashVec=landmark2hash(landmarkVec, songId);
disp(hashVec);

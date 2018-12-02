%% hash2landmark
% 
%% Syntax
% * 		landmarkVec=hash2landmark(hashVec)
%% Description
%
% <html>
% <p>Convert a set of <time hashValue> pairs ready from store
% <p>into a set of 4-entry landmarks <t1 f1 f2 dt>.
% <p>If H is 3 cols, first col (song ID) is discarded.
% </html>
%% Example
%%
%
hashVec = [0 2 5507096; 0 2 5508138; 0 2 5536702; 0 3 7993729; 0 3 7963030];
landmarkVec = hash2landmark(hashVec);
disp(landmarkVec);

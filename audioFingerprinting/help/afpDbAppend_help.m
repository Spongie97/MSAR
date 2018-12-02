%% afpDbAppend
% Append new entries in a databse for AFP
%% Syntax
% * 		afpDbAppend(oldDbPath, newAudioDir, newDbFileName)
%% Description
%
% <html>
% <p>Accoriding to your given old database path and new audio file directory,
% <p>this toolbox will add songs to the new database and output the dbFile
% <p>with your new dbFileName.
% </html>
%% Example
%%
%
addpath(fullfile(afptRoot, 'mp3_toolbox/'));
oldDbPath = fullfile(afptRoot, 'dataset/database/db_10.mat');
newAudioDir = fullfile(afptRoot,'dataset/mp3/');
newDbFileName = 'new_testDb';
afpDbAppend(oldDbPath, newAudioDir, newDbFileName);

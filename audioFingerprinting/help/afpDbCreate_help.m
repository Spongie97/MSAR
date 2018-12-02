%% afpDbCreate
% Create a database for AFP from a given audio directory
%% Syntax
% * 		db=afpDbCreate(audioDir, afpOpt)
%% Description
% 		Create the database file according to the give directory of audio files.
%% Example
%%
%
audioDir = fullfile(afptRoot, 'dataset/music4db');
afpOpt=afpOptSet;
db=afpDbCreate(audioDir, afpOpt);

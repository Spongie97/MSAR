% Check smoothness of the labeled pitch vectors
% Roger Jang, 20150416

close all; clear all;

% Add necessary toolboxes
addpath C:/users/mavis/Documents/matlab/utility
addpath C:/users/mavis/Documents/matlab/utility

% Specify the folder for audio files
pvDir='C:/users/mavis/Documents/matlab/testwave';

% Set up options
opt.type='singing';
opt.maxPitch=80;
opt.maxPitchDiff=5;
opt.outputDir='C:/users/mavis/Documents/matlab/testwave/';

% Check smoothness of pitch
pvSmoothCheck(pvDir, opt);
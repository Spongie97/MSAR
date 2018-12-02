% Check smoothness of the labeled pitch vectors
% Roger Jang, 20150416

close all; clear all;

% Add necessary toolboxes
addpath C:\Program Files\MATLAB\R2016b\toolbox\utility
addpath C:\Program Files\MATLAB\R2016b\toolbox\sap

% Specify the folder for audio files
pvDir='E:\MSAR\recording';

% Set up options
opt.type='singing';
opt.maxPitch=80;
opt.maxPitchDiff=5;
opt.outputDir=tempname;

% Check smoothness of pitch
pvSmoothCheck(pvDir, opt);
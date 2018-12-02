% Main program for generating the PV files for evaluation.
% To distinguish from GT, these PV files have extension of "pv2".

% ====== Add necessary toolboxes to the search path
toolboxDir='/Users/spongie/Downloads/MathWorks/R2017a/archives/';
addpath([toolboxDir, 'utility']);
addpath([toolboxDir, 'sap']);

% ====== Define the directory of the wave files to be tested
auDir='/Users/spongie/Documents/MATLAB/exampleProgram/pitchTracking_TestSet';			% Replace this with the recordings of this year, which contains audio files without PV files
outputPvDir='b04705005_pv2';	% All the generated PV files are put here, so you can compress the folder for upload. Please follow the convention of "studentID_pv2".

% ====== Read wave files and the corresponding PV files (if exist)
fprintf('Read wave files from "%s"...\n', auDir);
auSet=ptAuSetRead(auDir);
fprintf('Collected %d wave files,\n', length(auSet));
if isempty(auSet), error('Cannot read any wave files from the given directory "%s"!\n', auDir); end

% ====== Compute predicted pitch and save pv files for further performance evaluation
ptOpt=myPtOptSet;
[recogRate, auSet, time]=ptPerfEval(auSet, ptOpt);
fprintf('Overall recognition rate = %.2f%%\n', recogRate*100);
fprintf('Overall time for %d files = %g sec\n', length(auSet), time);
fprintf('Average time per file = %g sec\n', mean([auSet.time]));

%% ====== Write pv files to output folder
%outputPvPath=[tempdir, outputPvDir];
outputPvPath=outputPvDir;
if ~exist(outputPvPath, 'dir')
	fprintf('Creating output directory: %s\n', outputPvPath);
	[status, message, messageid]=mkdir('.', outputPvPath);
end
for i=1:length(auSet)	% D:\users\jang\temp\ptPredict_noGt/b00902024/descendants of the dragon_Jian-Fu Li_0.wav
	[parentPath, mainName, extName]=fileparts(auSet(i).file);	% parentPath='D:\users\jang\temp\ptPredict_noGt/b00902024'
	[topPath, personDir]=fileparts(parentPath);	% topPath='D:\users\jang\temp\ptPredict_noGt', personDir='b00902024'
	personPath=fullfile(outputPvPath, filesep, personDir);
	if ~exist(personPath, 'dir')
		fprintf('Creating output directory: %s\n', personPath);
		[status, message, messageid]=mkdir(personPath);
	end
	pvFile=fullfile(personPath, filesep, [mainName, '.pv2']);
%	fprintf('%d/%d: Writing %s...\n', i, length(auSet), pvFile);
	asciiWrite(auSet(i).computedPitch, pvFile, '%f');
end
fprintf('\nPlease compress the folder "%s" and upload it for evaluation!\n\n', outputPvPath);

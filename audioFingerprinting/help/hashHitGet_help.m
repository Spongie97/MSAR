%% hashHitGet
% 
%% Syntax
% * 		hitList = hashHitGet(hashVec, hashTable, afpPrm)
%% Description
%
% <html>
% <p>Return hit list from song hash table for a given particular hashes
% <p>Row of hashVec = [0, t1, hashKey]
% <p>Row of hitList = [songId, qTimeOffset, hashKey]
% </html>
%% Example
%%
%
		dbFile = fullfile(afptRoot, 'dataset/database/db_10.mat');
		load(dbFile);	% Load hashTable, audioData
		afpPrm = afpOptSet;
		waveFile=fullfile(afptRoot, 'dataset/test_corpus/The_power_of_love.wav');
		[y, fs, nbits]=wavread(waveFile);
		y=mean(y,2);
		lmVec = landmarkFind(y, fs, afpPrm);		% lmVec: landmark vec, with each row = [t1 f1 f2 t2-t1]
 		%Augment with landmarks calculated half-a-window advanced too
		hopSize = 0.064*fs;
		lmVec = [lmVec; landmarkFind(y(round(1/4*hopSize):end), fs, afpPrm)];
		lmVec = [lmVec; landmarkFind(y(round(2/4*hopSize):end), fs, afpPrm)];
		lmVec = [lmVec; landmarkFind(y(round(3/4*hopSize):end), fs, afpPrm)];
		hashVec = unique(landmark2hash(lmVec), 'rows'); %  Row of hashVec: [0, t1, hashKey]
		hitList = hashHitGet(hashVec, hashTable);
		disp(hitList);

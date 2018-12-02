%% afpHashHitGet
% Return hash values in a hash table given a set of given landmarks
%% Syntax
% * 		hitList = afpHashHitGet(hashList, hashTable, afpOpt)
%% Description
%
% <html>
% <p>Return hit list from song hash table for a given particular hashes
% <p>Row of hashList = [hashKey, t1]
% <p>Row of hitList = [songId, qTimeOffset, hashKey, lmStartTimeInDb, lmStartTimeInQuery]
% </html>
%% Example
%%
%
		audioDir = fullfile(afptRoot, 'dataset/music4db');
		afpOpt=afpOptSet;
		db=afpDbCreate(audioDir, afpOpt);
		afpOpt = afpOptSet;
		auFile=fullfile(afptRoot, 'dataset/music4query/The Power Of Love_xxx_noisy01.mp3');
		au=myAudioRead(auFile); y=au.signal; fs=au.fs;
		y=mean(y,2);
		lmList = afpFeaExtract(y, fs, afpOpt);		% lmList: each row = [t1 f1 f2 t2-t1]
 		%Augment with landmarks calculated half-a-window advanced too
		hopSize = 0.064*fs;
		lmList = [lmList; afpFeaExtract(y(round(1/4*hopSize):end), fs, afpOpt)];
		lmList = [lmList; afpFeaExtract(y(round(2/4*hopSize):end), fs, afpOpt)];
		lmList = [lmList; afpFeaExtract(y(round(3/4*hopSize):end), fs, afpOpt)];
		hashList = unique(afpFea2hash(lmList), 'rows');	%  Row of hashList: [0, t1, hashKey]
		hitList = afpHashHitGet(hashList, db.hashTable);
		disp(hitList);

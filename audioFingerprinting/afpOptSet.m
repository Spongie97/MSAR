function afpOpt=afpOptSet
%afpOptSet: Set the options for AFP 
%
%	Usage:
%		afpOpt = afpOptSet
%
%	Description:
%		Set audio fingerprinting parameter
%
%	Example:
%		afpOpt = afpOptSet
%
%	Category: Audio Fingerprinting
%	Roger Jang, Pei-Yu Liao, 20130716	

addpath /Users/spongie/Downloads/MathWorks/R2017a/archives/utility
addpath /Users/spongie/Downloads/MathWorks/R2017a/archives/sap
addpath /Users/spongie/Documents/MATLAB/audioFingerprinting

% ====== Options for Hash tabl: A hash key is 24 bits: 9 bits of f1, 8 bits of f2-f1, 7 bits of delta-T
afpOpt.bitNum4f1=9;		% 9 bits for f1 (orig 8)
afpOpt.bitNum4df=8;		% 8 bits for f2-f1 (orig 6)
afpOpt.bitNum4dt=7;		% 7 bits for dt (orig 6)
afpOpt.bitNum4hashKey=afpOpt.bitNum4f1+afpOpt.bitNum4df+afpOpt.bitNum4dt;	% 24 bits for hash key (orig 20)
afpOpt.keyNum=2^afpOpt.bitNum4hashKey;			% No. of hash keys = 2^24 (orig 2^20)
afpOpt.maxEntryPerKey=inf;	% Max no. of hash values per hash key (orig 20)
% ====== Options for landmark extraction
afpOpt.lmDensity=40;		% 40. Landmark density (orig 20)
afpOpt.timeSize=16384;		% 2^14. hashValue = int32(songId*TIMESIZE + toffs)
afpOpt.maxPairsPerPeak=10;	% 10. Orig 3
afpOpt.f_sd=30;
afpOpt.maxPeaksPerFrame=10;	% 10. Orig 5
afpOpt.hpf_pole=0.98;
afpOpt.freqHalfSpan=127;	% This should be less than 2^bitNum4df/2 (127, orig 31)
afpOpt.timeSpan=96;		% This should be less than 2^bitNum4dt (96, orig 63)
afpOpt.frameDuration=128;	% Frame duration in ms, corresponding to 1024 points (128, orig 64ms)
afpOpt.frameShift=64;		% Frame shift in ms (64, orig 32)
afpOpt.targetFs=8000;
% ====== Options for performance evaluation
afpOpt.queryLength=10;		% Query will be chopped into this length (in sec) for performance evaluation
afpOpt.queryHopLength=10;	% Hop size (in sec) between consecutive queries
afpOpt.timeTolerance=1;		% Time tolerance for time-matched landmark
afpOpt.queryRepeatCount=4;	% No. of repeat extraction of LM (frameSkip is divided into this number)

% ====== new options created by zenhon ===
%% preprocess
afpOpt.PeakCompareOrigin=0;
afpOpt.StereoToMonoConcat=0;
afpOpt.StereoToMonoOneChannel=0;
afpOpt.useSpecMinThreshold=0;
afpOpt.specMatThreshold=0;
afpOpt.vertical_highpass=0;
afpOpt.usephilip=0;
%% rerank
afpOpt.w=[0.929816808072893,0.246710157526972,0.353613456351601];
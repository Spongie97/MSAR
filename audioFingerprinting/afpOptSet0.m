function afpOpt=afpOptSet0
%afpOptSet0: Set the basic options for AFP 
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

afpOpt.bitNum4f1=8;		% 9 bits for f1
afpOpt.bitNum4df=6;		% 8 bits for f2-f1
afpOpt.bitNum4dt=6;		% 7 bits for dt
afpOpt.bitNum4hashKey=afpOpt.bitNum4f1+afpOpt.bitNum4df+afpOpt.bitNum4dt;	% 24 bits for hash key (orig 20)
afpOpt.keyNum=2^afpOpt.bitNum4hashKey;			% No. of hash keys
afpOpt.maxEntryPerKey=20;	% Max entry per hash key
afpOpt.lmDensity=20;	% Landmark density
afpOpt.timeSize=16384;	% 2^14. hashValue = int32(songId*TIMESIZE + toffs)
afpOpt.maxPairsPerPeak=3;
afpOpt.f_sd=30;
afpOpt.maxPeaksPerFrame=5;
afpOpt.hpf_pole=0.98;
afpOpt.freqHalfSpan=31;
afpOpt.timeSpan=63;
afpOpt.frameDuration=64;	% Frame duration in ms
afpOpt.frameShift=32;		% Frame shift in ms
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
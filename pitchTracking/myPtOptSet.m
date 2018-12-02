function ptOpt=myPtOptSet
%myPtOptSet: Returns the options (parameters) for PT

ptOpt.frameDuration=32;		% Duration (in ms) of a frame
ptOpt.overlapDuration=0;	% Duration (in ms) of overlap
ptOpt.useVolThreshold=0;	% Pitch with small volume is set to zero.
                            % Note that this should be set to 0 since our
                            % performance is based on "raw pitch accuracy"
                            % instead of "overall accuracy"
ptOpt.frame2pitchOpt=ptOptSet(16000, 16, 1);
%ptOpt.frame2pitchOpt=frame2pitch('defaultOpt');	% Buggy!
% ====== You can change options for frame2pitch
ptOpt.frame2pitchOpt.pdf='acf';


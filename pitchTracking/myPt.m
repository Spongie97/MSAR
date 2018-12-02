function pitch=myPt(au, ptOpt, showPlot);
% myPt: Pitch tracking from audio
%
%	Usage:
%		pitch=myPt(au, ptOpt, showPlot);
%			au: audio
%			ptOpt: options for pitch
%			showPlot: 1 for plotting, 0 for not plotting
%			pitch: computed pitch
%
%	Example:
%		waveFile='londonBridgeIsFallingDown.wav';
%		au=myAudioRead(waveFile);
%		ptOpt=myPtOptSet;
%		ptOpt.useVolThreshold=1;
%		showPlot=1;
%		myPt(au, ptOpt, showPlot);

%	Roger Jang, 20110531, 20130416

if nargin<1, selfdemo; return; end
if nargin<2, ptOpt=myPtOptSet; end
if nargin<3, showPlot=0; end

if ischar(au), au=myAudioRead(au); end	% If the give au is a file name
y=au.signal; fs=au.fs; nbits=au.nbits;
y=y-mean(y);
frameSize=round(ptOpt.frameDuration*au.fs/1000);
overlap=round(ptOpt.overlapDuration*au.fs/1000);
frameMat=enframe(y, frameSize, overlap);
frameNum=size(frameMat, 2);
pitch=zeros(frameNum, 1);
volume=zeros(frameNum, 1);

% ====== Compute volume & its threshold (計算音量 & 音量門檻值)
volume=frame2volume(frameMat);
volMax=max(volume);
volMin=min(volume);
ptOpt.volTh=volMin+0.1*(volMax-volMin);
% ====== Compute pitch 計算音高（會用到音量門檻值）
ptOpt.frame2pitchOpt.fs=fs;
for i=1:frameNum
	frame=frameMat(:, i);
	pitch(i)=frame2pitch(frame, ptOpt.frame2pitchOpt);
end
pitch0=pitch;

if ptOpt.useVolThreshold
	pitch(volume<ptOpt.volTh)=0;	% Set pitch to zero if the volume is too low
end

% ====== Plotting (畫圖)
if showPlot
	frameTime=frame2sampleIndex(1:frameNum, frameSize, overlap)/fs;
	subplot(3,1,1);
	plot((1:length(y))/fs, y); set(gca, 'xlim', [-inf inf]);
	title('Waveform');
	subplot(3,1,2);
	plot(frameTime, volume, '.-'); set(gca, 'xlim', [-inf inf]);
	line([0, length(y)/fs], ptOpt.volTh*[1, 1], 'color', 'r');
	title('Volume');
	subplot(3,1,3);
	pvFile=[au.file(1:end-3), 'pv'];
	tPitch=nan*pitch;
	cPitch=pitch; cPitch(cPitch==0)=nan;
	if exist(pvFile, 'file')
		tPitch=asciiRead(pvFile); tPitch(tPitch==0)=nan;
		plot(frameTime, pitch0, 'o-c', frameTime, cPitch, 'o-g', frameTime, tPitch, '.-k');
	%	title('Cyan: computed pitch, green: volume-thresholded computed pitch, black: target pitch');
		legend({'Computed pitch', 'Volume-thresholded computed pitch', 'Target pitch'}, 'location', 'northOutside', 'orientation', 'horizontal');
	else
		plot(frameTime,	 pitch0, 'o-c' , frameTime, cPitch, 'o-g');
	%	title('Cyan: computed pitch, green: volume-thresholded computed pitch');
		legend({'Computed pitch', 'Volume-thresholded computed pitch'}, 'location', 'northOutside', 'orientation', 'horizontal');
	end
	axis tight;
	xlabel('Time (second)'); ylabel('Semitone');
end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);
strEval(mObj.example);
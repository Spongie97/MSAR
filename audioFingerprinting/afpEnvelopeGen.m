function output = afpEnvelopeGen(signal, sigma, showPlot)
%afpEnvelopeGen: Generate the envelope for a given signal for AFP
%
%	Usage:
%		output = afpEnvelopeGen(signal)
%		output = afpEnvelopeGen(signal, sigma)
%		output = afpEnvelopeGen(signal, sigma, showPlot)
%
%	Description:
%		Each postive local maximum in signal is convolved with the a gaussian, and the output is the pointwise max of all of these.
%		If sigma is the standard deviation of a gaussian used as the spreading function.
%
%	Example:
%		signal=[0.892;0.795;2.28;3.55;3.98;4.02;4;3.58;3.57;3.14;2.54;2.82;2.27;2.13;1.87;2.27;1.9;1.89;1.96;2.22;2.26;2;1.83;1.37;1.18;1.7;1.46;1.15;1.14;0.553;0.867;0.693;1.02;1.54;1.39;0.861;0.897;0.589;1.24;1.85;1.91;2;1.83;1.79;1.26;0.741;1.03;0.706;0.817;1.36;1.56;0.824;0.863;0.737;1.03;1.21;1.24;1.15;0.967;1.24;1.2;1.07;1.32;0.847;1.63;1.63;1.33;1.2;1.15;0.9;0.628;0.702;0.697;1.46;1.32;1.07;0.83;0.372;1.09;1.32;1.07;0.881;1.2;1.15;1.45;1.4;0.728;1.12;1.32;1.52;1.49;1.14;1.1;1.17;1.44;1.22;1.14;1.21;1.58;1.64;1.55;1.49;1.48;0.965;0.678;1;1.12;0.652;0.612;0.598;1.02;1.06;1.28;1.38;1.25;0.955;1.14;0.558;0.511;1.15;1.05;1.29;1.31;1.36;1.54;1.88;1.88;1.9;1.95;1.87;1.46;1.04;1.08;1.13;1.18;1.06;1.44;1.04;0.508;0.627;0.448;0.282;0.515;0.877;1.02;0.383;0.678;0.365;0.416;0.397;0.515;0.651;0.983;0.523;0.706;0.642;0.788;0.936;0.395;0.33;0.878;0.904;0.726;0.653;0.618;0.683;0.212;0.58;0.557;0.58;0.829;0.572;1.18;0.872;0.426;1.17;1.54;0.989;0.646;0.847;0.829;1.04;1.33;1.4;1.07;1.16;1.31;1.36;1.07;1.09;1.16;0.815;1.16;1.14;1.16;1.06;0.974;1.44;1.42;1.47;0.978;0.394;0.915;1.09;1.01;0.512;1.1;1.31;1.3;0.82;0.628;1.02;1.14;1.43;1.37;0.762;0.936;0.797;0.111;0.0383;0.4;0.659;0.935;0.97;1.2;0.611;0.599;0.595;1.13;0.896;0.605;0.637;1.13;1.19;0.615;0.68;1.44;1.45;0.615;1.39;1.17;0.739;0.717;0.671;0.0561;0.381;1.02;0.835;0.66;0.755;1.2;1.18;0.963;1.1;0.685;0.901;0.401]
%		sigma=30;
%		output = afpEnvelopeGen(signal, sigma, 1);
%
%	Category: Utility
%	Roger Jang, Pei-Yu Liao, 20130225
%
% 2009-03-15 Dan Ellis dpwe@ee.columbia.edu

if nargin<1, selfdemo; return; end
if nargin<2, sigma=4; end
if nargin<3, showPlot=0; end

if length(sigma)==1
	W = 4*sigma;
	gaussian = exp(-0.5*[(-W:W)/sigma].^2);
end

index1=localMax(signal, 'keepBoth');
index2=signal>0;
locMaxIndex=find(index1&index2);
signalLen = length(signal);
gaussianLen=length(gaussian);
halfSpan = 1+round((length(gaussian)-1)/2);
if isempty(locMaxIndex)
%	fprintf('Warning: Cannot find any local max. in %s\n', mfilename);
	output=0*signal;
	return;
end

gaussianSet=zeros(signalLen+gaussianLen, length(locMaxIndex));
for i=1:length(locMaxIndex)
	gaussianSet(locMaxIndex(i):locMaxIndex(i)+gaussianLen-1, i) = signal(locMaxIndex(i))*gaussian;
end
gaussianSet=gaussianSet(halfSpan:halfSpan+signalLen-1, :);
output=max(gaussianSet, [], 2);

if showPlot
%	subplot(2,1,1);
%	plot(gaussian);
%	subplot(2,1,2);
	h(1)=plot(1:signalLen, signal);
	h(2)=line(locMaxIndex, signal(locMaxIndex), 'color', 'r', 'marker', '.', 'linestyle', 'none');
	hold on; plot(1:signalLen, gaussianSet); hold off
	h(3)=line(1:signalLen, output, 'marker', 'o', 'linestyle', 'none');
	legend(h, 'Original signal', 'Positive local maxima', 'Final output');
	axis tight
end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);

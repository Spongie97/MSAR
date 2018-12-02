function afptRootPath=afptRoot
%afptRoot: Root of AFPT (Audio Fingerprinting Toolbox)
%
%	Usage:
%		afptRootPath=afptRoot
%
%	Description:
%		afptRootPath=afptRoot returns a string indicating the installation
%		folder of AFPT (Audio Fingerprinting Toolbox).
%
%	Example:
%		fprintf('The installation root of AFPT is %s\n', afptRoot);
%
%	Category: Utility
%	Roger Jang, Pei-Yu Liao, 20130301

[afptRootPath, mainName, extName]=fileparts(which(mfilename));
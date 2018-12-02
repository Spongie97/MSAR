function out=toolboxInfo
%toolboxInfo: Toolbox information
%
%	Usage:
%		out=toolboxInfo
%
%	Description:
%		out=toolboxInfo returns the info of the toolbox (where this file resides)
%
%	Example:
%		out=toolboxInfo

%	Category: Utility
%	Roger Jang, 20130225, 20160205

out.name='Audio Fingerprinting toolbox';
out.representativeFcn='afpQueryMatch';
out.website='http://mirlab.org/jang/matlab/toolbox/audioFingerprinting';
out.version='1.5';
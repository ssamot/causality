function dprintf(fp, varargin)
%dprintf(fp, varargin))
% Debug printf
% if fp=0, do nothing
% if fp=1 or 2, printf to  stdout or stderr
% if fp>0, print to file using handle fp

% Isabelle Guyon -- Feb 2013

if fp>0
	fprintf(fp, varargin{:});
end

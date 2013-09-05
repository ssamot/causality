function lprintf(fp, varargin)
%lprintf(fp, varargin))
% Log printf
% if fp=0, do nothing
% if fp=1 or 2, printf to  stdout or stderr
% if fp>0, print to file using handle fp AND to stderr

% Isabelle Guyon -- Feb 2013

if fp>1
    fprintf(2, varargin{:});
end
if fp>2
	fprintf(fp, varargin{:});
end

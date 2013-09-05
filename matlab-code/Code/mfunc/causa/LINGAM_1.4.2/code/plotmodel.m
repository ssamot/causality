function plotmodel(B, k, varargin)
% PLOTMODEL Plot a causal model.
%
% Syntax: plotmodel(B, k, ...)
%
% Plots a causal model as a directed acyclic graph. The graph
% layout is done with Graphviz, see www.graphviz.org for details.
% You need either Graphviz installed in your system or a Java
% interpreter with internet connection.
%
% Intended usage is to first call LiNGAM to do the causal discovery
% and then to call 'plotmodel' to visualize the estimated model.
%
% Example:
%   [B stde ci k] = lingam(data);
%   plotmodel(B, k);
%
% Also latent models can be plotted with dashed nodes and incoming/
% outgoing arcs. Use 'latent' argument with logical column array
% indicating the latent variables (in causal order).
%
% Example:
%  latent = logical([0 1 0 0]');
%  plotmodel(B, k, 'latent', latent, 'target', 'psviewer');
%
% To plot on a specific Matlab figure, use the 'target' argument
% with value 'matlab:[handle]', e.g. 'matlab:3' to plot on figure
% no. 3.
%
% Required input arguments:
%   B - the weight matrix.
%   k - the causal order of variables.
%
% Optional input arguments in name, value pairs [default]:
%   'target'   - target of output ['matlab' (Octave: 'psviewer')]:
%     'matlab'     - plot graph on Matlab figure window
%     'java'       - plot graph with Grappa. Uses a remote layout server
%                    if 'dot' can't be found. In that case, needs an
%                    internet connection.
%     'psviewer'   - plot graph with a PS viewer. Default for Octave.
%                    Edit file 'settings.m' to set your PS viewer.
%     '[filename]' - plot graph on eps-file '[filename]'
%   'varnames' - names of variables in cell array of strings [{'x1' 'x2' ...}]
%   'plotarcs' - plot labels for arcs (boolean) [true]
%   'layout'   - layout of the graph ['td']:
%                'td'     - plot nodes in hierarhial layers, top-down
%                'lr'     - plot nodes in hierarhial layers, left to right
%                'circle' - plot nodes in cirle (not possible with
%                           'target', 'java')
%   'nodeshapes' - cell array of node shapes ['ellipse']
%   'nodestyles' - cell array of node styles ['solid']
%   'arcstyles'  - cell array of arc styles ['solid']
%   'arccolors'  - cell array of arc colors ['black']
%   'arclabels'  - cell array of arc labels ['B(j, i)']
%   'latent'     - a logical column vector of latent variables [[]]
%

% Check if we are running Octave
isoctave = exist('OCTAVE_VERSION');

% Check number of input arguments
if nargin < 2 || rem(nargin, 2) ~= 0
    error('number of input arguments must be >= 2 and even');
end

% Initialize variables
dims = size(B, 1);
adj = B(k, k)';

if isoctave
    target = 'psviewer';
else
    target = 'matlab';
end
handle = [];  % Matlab figure handle, [] = create a new figure

varnames = cell([dims 1]);
for i = 1:dims
    varnames{i} = strcat('x', int2str(k(i)));
end

plotarcs = true;
layout = 'td';
nodeshapes = cell(dims, 1);
nodeshapes(:) = {'ellipse'};
nodestyles = cell(dims, 1);
nodestyles(:) = {'solid'};
adjmat = adj ~= 0;
arcstyles = cell(dims);
arcstyles(adjmat) = {'solid'};
arccolors = cell(dims);
arccolors(adjmat) = {'black'};
latent = [];

% Handle optional input arguments
for i = 1:2:(nargin - 2)
    switch varargin{i}
     case 'target',     [target handle] = parsetarget(varargin{i + 1});
     case 'plotarcs',   plotarcs = varargin{i + 1};
     case 'layout',     layout = varargin{i + 1};
     case 'nodeshapes', nodeshapes = varargin{i + 1};
     case 'nodestyles', nodestyles = varargin{i + 1};
     case 'arcstyles',  arcstyles = varargin{i + 1};
     case 'arccolors',  arccolors = varargin{i + 1};
     case 'arclabels',  arclabels = varargin{i + 1};
     case 'latent',     latent = varargin{i + 1};
     case 'varnames'
      tempnames = varargin{i + 1};
      for i = 1:dims
	  varnames{i} = tempnames{k(i)};
      end
     otherwise, warning('unknown input argument: %s\n', varargin{i});
    end
end

% If the latent variables are given, force the drawing attributes
% of nodes and incoming/outgoing arcs to dashed
nodestyles(latent) = {'dashed'};
latentindices = find(latent)';
for i = latentindices
    in = adjmat(:, i);
    out = adjmat(i, :);
    arcstyles(i, out) = {'dashed'};
    arcstyles(in, i) = {'dashed'};
end

% Set filenames
dotfile = 'plotmodel_temp.dot';
switch target
 case 'matlab'
  if isoctave
      format = 'ps';
      imgfile = 'plotmodel_temp.ps';
  else
      format = 'png';
      imgfile = 'plotmodel_temp.png';
  end
 case 'java'
  % no need for image file
 case 'psviewer'
  format = 'ps';
  imgfile = newtempfile('ps');
  settings % find out the PS viewer
 otherwise
  format = 'ps';
  imgfile = target;
end

% Generate labels for arcs
if ~exist('arclabels')
    if plotarcs
	arclabels = double2labels(adj);
    else
	arclabels = double2labels(zeros(dims));
    end
end

% Call graph2dot to write the graph to a dot-file
graph2dot(adj, dotfile, ...
	  'nodelabels', varnames, ...
	  'nodeshapes', nodeshapes, ...
	  'nodestyles', nodestyles, ...
	  'arclabels', arclabels, ...
	  'arcstyles', arcstyles, ...
	  'arccolors', arccolors, ...
	  'arclabels', arclabels, ...
	  'leftright', strcmp(layout, 'lr'));

if strcmp(target, 'java')
    % Call Grappa to produce the picture
    libstr = '-cp ../lib/grappa1_2.jar:../lib/lingam.jar';
    classstr = ' lingam.GraphPlotter ';
    if isoctave
	progcall = strcat('java ', libstr, classstr, dotfile);    
    else
	progcall = strcat(['java ', libstr, classstr, dotfile]);
    end
else
    % Call Graphviz to produce the picture
    if strcmp(layout, 'circle')
	prog = 'circo';
    else
	prog = 'dot';
    end
    
    if isoctave
	progcall = strcat(prog, ' -T', format, ' ', dotfile, ' -o ', imgfile);
    else
	progcall = strcat([prog, ' -T', format, ' ', dotfile, ...
			   ' -o ', imgfile]);
    end
end

% Call Graphviz/Grappa
if ispc
    shell = 'dos';
else
    shell = 'unix';
end
shellcall = strcat(shell, '(''', progcall, ''')');
[status msg] = eval(shellcall);

if status
    if strcmp(target, 'java')
	error('calling Java caused an error: %s\n', msg);
    else
	error('calling "%s" caused an error: %s\n', prog, msg);
    end
end

switch target
 case 'matlab'
  % Read the image file
  if isoctave
      options = '-antialias';
      [img cmap] = imread(imgfile, options);
  else
      [img cmap] = imread(imgfile, 'png');
  end
  
  % Create a new window / set the current
  if isempty(handle)
      handle = figure;  % Create a new figure
      figx = 100;
      figy = 100;
  else
      figure(handle);   % Draw on the given figure
      if ~isoctave
	  position = get(handle, 'Position');
	  figx = position(1);
	  figy = position(2);
      end
  end
  
  % Resize the figure window
  if ~isoctave
      set(handle, 'Position', [figx figy size(img, 2) size(img, 1)]);
  end
  
  % Show the image and set the color map
  image(img);
  if isoctave
      toolow = find(cmap < 0.0);
      toohigh = find(cmap > 1.0);
      if any(toolow) || any(toohigh)
	  fprintf('Color map values are out of range [0 1]!\n');
      else
	  colormap(cmap);
      end
  else
      colormap(cmap);
      set(gca, 'Position', [0 0 1 1]);
      set(gca, 'XTick', []);
      set(gca, 'YTick', []);
  end
  delete(imgfile);
 case 'java'
  % nothing to do
 case 'psviewer'
  fprintf('graph plotted to file "%s"\n', imgfile);
  if isoctave
      progcall = strcat(PSVIEWER, ' ', imgfile, ' &');    
  else
      progcall = strcat([PSVIEWER, ' ', imgfile, ' &']);
  end
  shellcall = strcat(shell, '(''', progcall, ''')');
  [status msg] = eval(shellcall);
  if status
      error('calling "%s" caused an error: %s\n', prog, msg);
  end
 otherwise
  fprintf('graph plotted to file "%s"\n', imgfile);
end

delete(dotfile);


% -----------------------------------------------------------------------------
function name = newtempfile(suffix)
% NEWTEMPFILE Create a new temporary file.

prefix = 'plotmodel_temp_'; % common suffix for all temp files
maxnumber = 0;

files = dir('.');
for i = 1:length(files)
    filename = files(i).name;

    dotindex = find(filename == '.');  % works for Matlab and Octave
    if isempty(dotindex)
	continue;
    end
    
    suff = filename(dotindex + 1:length(filename));
    if strcmp(suff, suffix) & findstr(filename, 'plotmodel_temp_') == 1
	number = str2num(filename(16:dotindex - 1));
	if number > maxnumber
	    maxnumber = number;
	end
    end
end

name = strcat('plotmodel_temp_', num2str(maxnumber + 1), '.', suffix);


% -----------------------------------------------------------------------------
function [target, handle] = parsetarget(s)
% PARSETARGET Parse target and a possible figure handle.

colonind = find(s == ':');  % works for Matlab and Octave
if isempty(colonind)
    target = s;
    handle = [];
else 
    colonind = colonind(1);
    target = s(1:colonind - 1);
    handle = str2num(s(colonind + 1:length(s)));
end

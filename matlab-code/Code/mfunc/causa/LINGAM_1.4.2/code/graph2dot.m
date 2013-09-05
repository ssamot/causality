function graph2dot(adj, filename, varargin)
% GRAPH2DOT Writes a dot file representing an adjacency matrix.
%
% Syntax: graph2dot(adj, filename, ...)
%
% Required input arguments:
%   adj      - the adjacency matrix of the graph.
%   filename - name for the dot file.
%
% Optional input arguments in name, value pairs [default]:
%   'nodelabels' - nodelabels{i} is a string attached to the node i ['i']
%   'nodeshapes' - cell array of node shapes ['ellipse']
%   'nodestyles' - cell array of node styles ['solid']
%   'arclabels'  - arclabels{i,j} is a string attached to the i-j arc ['']
%   'arcstyles'  - cell array of arc styles ['solid']
%   'width'      - maximum width in inches [10]
%   'height'     - maximum height in inches [10]
%   'leftright'  - true for left to right layout, false for top-down [false]
%

% This funtion is adapted from 'graph_to_dot' in GraphViz Matlab
% interface by Kevin Murphy, available from
%   http://www.cs.ubc.ca/~murphyk/Software/GraphViz/graphviz.html
%
% First version written by Kevin Murphy 2002.
% Modified by Leon Peshkin, Jan 2004.
% Bugfix by Tom Minka, Mar 2004.
% Modified by Antti Kerminen, Aug 2005.
%   - added handling of arc labels
%   - added possibility to use bold, dashed, and red arc styles
%   - added support for Octave
%   - changed filename from optional to required argument
%   - removed all code related to undirected arcs
%   - some changes in documentation and code layout
% Modified by Antti Kerminen, Nov 2005.
%   - added new input arguments: nodeshapes, nodestyles, arcstyles,
%     pos
%   - minor code refactoring
% Modified by Antti Kerminen, Mar 2006
%   - removed input arguments: boldarcs, dashedarcs, redarcs, pos

% Check if we are running Octave
isoctave = exist('OCTAVE_VERSION');

nnodes = size(adj, 1);

% Set default args
nodelabels = cell(nnodes, 1);
for i = 1:nnodes
    nodelabels{i} = num2str(i);
end
nodeshapes = cell(nnodes, 1);
nodeshapes(:) = {'ellipse'};
nodestyles = cell(nnodes, 1);
nodestyles(:) = {'solid'};
arclabels = [];
arcstyles = cell(nnodes);
arccolors = cell(nnodes);
arccolors(:) = {'black'};
width = 10;
height = 10;
leftright = 0;

% Get optional args
for i = 1:2:(nargin - 2)
    switch varargin{i}
     case 'nodelabels', nodelabels = varargin{i + 1};
     case 'nodeshapes', nodeshapes = varargin{i + 1};
     case 'nodestyles', nodestyles = varargin{i + 1};
     case 'arclabels',  arclabels = varargin{i + 1};
     case 'arcstyles',  arcstyles = varargin{i + 1};
     case 'arccolors',  arccolors = varargin{i + 1};
     case 'width',      width = varargin{i + 1};
     case 'height',     height = varargin{i + 1};
     case 'leftright',  leftright = varargin{i + 1};
    end
end

% Construct a format string for nodes
nodeformat = '  %d [label = "%s", shape = %s, style = "%s"];\n';
  
% Construct a format string for edges
if isempty(arclabels)
    attributes = 'style = %s, color = %s';
else
    attributes = 'style = %s, color = %s, label = "%s"';
end

if isoctave  % no need/support for brackets
    edgeformat = strcat('  %d -> %d [', attributes, '];\n');
else
    edgeformat = strcat(['  %d -> %d [', attributes, '];\n']);
end

% Write the file
fid = fopen(filename, 'w');

fprintf(fid, 'digraph G {\n');
fprintf(fid, '  center = 1;\n');
fprintf(fid, '  size = \"%d, %d\";\n', width, height);
if leftright
    fprintf(fid, '  rankdir = LR;\n');
end

% Write nodes
for node = 1:nnodes
    fprintf(fid, nodeformat, node, nodelabels{node}, nodeshapes{node}, ...
	    nodestyles{node});
end

% Write edges
for node1 = 1:nnodes
    arcs = find(adj(node1, :));
    for node2 = arcs
	style = arcstyles{node1, node2};
	color = arccolors{node1, node2};
	if isempty(arclabels)
	    fprintf(fid, edgeformat, node1, node2, style, color);
	else
	    fprintf(fid, edgeformat, node1, node2, style, color, ...
		    arclabels{node1, node2});
	end
    end
end

fprintf(fid, '}');
fclose(fid); 

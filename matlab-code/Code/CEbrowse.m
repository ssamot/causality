% -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-
%
%                               BROWSER FOR THE
%                    CHALEARN CAUSE-EFECT PAIR CHALLENGE
%    
%               Isabelle Guyon -- isabelle@clopinet.com -- February 2013
%                                   
% -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-
%
% DISCLAIMER: ALL INFORMATION, SOFTWARE, DOCUMENTATION, AND DATA ARE PROVIDED "AS-IS" 
% ISABELLE GUYON AND/OR OTHER CONTRIBUTORS DISCLAIM ANY EXPRESSED OR IMPLIED WARRANTIES, 
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
% FOR ANY PARTICULAR PURPOSE, AND THE WARRANTY OF NON-INFRIGEMENT OF ANY THIRD PARTY'S 
% INTELLECTUAL PROPERTY RIGHTS. IN NO EVENT SHALL ISABELLE GUYON AND/OR OTHER CONTRIBUTORS 
% BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
% ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF SOFTWARE, DOCUMENTS, 
% MATERIALS, PUBLICATIONS, OR INFORMATION MADE AVAILABLE FOR THE CHALLENGE. 

%% Initialization
clear D TRAIN TEST VALID
try close(h); end
this_dir=pwd;

% -o-|-o-|-o-|-o-|-o-|-o-|-o- BEGIN USER-PREFERENCES -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-

% 1) User-defined directories (no slash at the end of the names):
% --------------------------------------------------------------
% The present set up supposes that you are now in the directory Sample_code
% and you have the following directory tree, where Challenge is you project directory:
% Challenge/Data
% Challenge/Sample_code

my_root            = this_dir(1:end-5);               % Change that to the directory of your project
if ~exist(my_root, 'dir'), 
    fprintf('Please start in the Code/ directory');
end

public_data_dir    = [my_root '/CEdata/PUBLIC'];        % Path to the data.
private_data_dir   ='';                                 % Path to hidden labels and info available onlt to organizer.

code_dir           = [my_root '/Code'];               % Path to the code.

use_model   = 1;                                      % Use a model to classify pairs (can be slow...)

% -o-|-o-|-o-|-o-|-o-|-o-|-o-  END USER-PREFERENCES  -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-

set_path(code_dir); 

h=figure('Name', 'Cause-effect pair browser');
code_version;

offset=-20;

% Show the dataset name and pair number
n1=uicontrol('Parent', h, 'Position', [5 380+offset 60 40], 'FontSize', 20, 'ForegroundColor', [1 1 1]);
n2=uicontrol('Parent', h, 'Position', [5 350+offset 60 30], 'FontSize', 18, 'BackgroundColor', [.8 .8 .8]);

if use_model
    % Show the pair score
    n3=uicontrol('Parent', h, 'Position', [5 330+offset 60 20], 'FontSize', 12, 'BackgroundColor', [0 0 0], 'ForegroundColor', [1 1 1], 'String', 'Score:');
    n4=uicontrol('Parent', h, 'Position', [5 300+offset 60 30], 'FontSize', 12, 'BackgroundColor', [.8 .8 .8]);

    % Select a model (to classify pairs), no training
    mymodel=baseline;
end

% Select a set
select_set;

% Prev
u1=uicontrol('Parent', h, 'Position', [5 240+offset 60 40], 'FontSize', 12, 'BackgroundColor', [1 0.9 0.1], 'String', '< Prev', 'Callback', 'prev; show(D, num, h); show_score;');
% Next
u0=uicontrol('Parent', h, 'Position', [5 200+offset 60 40], 'FontSize', 12, 'BackgroundColor', [1 0.9 0.1], 'String', 'Next >', 'Callback', 'next; show(D, num, h); show_score;');
% Jump to another pair
u3=uicontrol('Parent', h, 'Position', [5 160+offset 60 40], 'FontSize', 12, 'BackgroundColor', [1 0.7 0.1], 'String', 'Jump to', 'Callback', 'jump; show(D, num, h); show_score;');
% Jump to another set
u4=uicontrol('Parent', h, 'Position', [5 120+offset 60 40], 'FontSize', 12, 'BackgroundColor', [0.95 0.55 0.35],  'String', 'New set', 'Callback', 'select_set;');





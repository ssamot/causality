% -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-
%
%                           COMPUTATION OF RESULTS FOR
%                       CHALEARN CAUSE-EFFECT PAIR CHALLENGE
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

% See also the function score_resu

% Initialization
clear R 
try close(h); end
this_dir=pwd;

%%-o-|-o-|-o-|-o-|-o-|-o-|-o- BEGIN USER-PREFERENCES -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-

% User-defined data path (no slash at end of dir names)
% -----------------------------------------------------
% The present set up supposes that you are now in the directory Sample_code
% and you have the following directory tree, where Challenge is you project directory:
% Challenge/Data
% Challenge/Results
% Challenge/Sample_code

my_root            = this_dir(1:end-5);               % Change that to the directory of your project
if ~exist(my_root, 'dir'), 
    fprintf('Please start in the Code/ directory');
end

starting_time      = datestr(now, 'yyyy_mm_dd_HH_MM');

data_dir           = [my_root '/CEdata'];             % Path to the data (supposed to have two subdirectories "PUBLIC" and "PRIVATE")
resu_dir           = [my_root '/Results'];            % Where the results will end up.  
code_dir           = [my_root '/Code'];               % Path to the code (this directory).
resu_filename      = [resu_dir '/Resu_' starting_time];% Result file

% Set data types 
types              = {'train', 'valid', 'test'};

%% -o-|-o-|-o-|-o-|-o-|-o-|-o- END USER-PREFERENCES -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-


% Set path
set_path(code_dir); 

% List the result files
if ~exist(resu_dir, 'dir'), error('No result directory'); return; end
direc = dir([resu_dir '/*.csv']); filenames = {};
[filenames{1:length(direc),1}] = deal(direc.name);

%% Loop over result files
fn=length(filenames);
tn=length(types);
R.filenames=filenames;
R.types=types;
Dependency=zeros(fn, tn);
Causality=zeros(fn, tn);
Confounding=zeros(fn, tn);
Score=zeros(fn, tn);

code_version;
for k=1:fn
    fprintf('Processing file: %s\n', filenames{k});
    for i=1:tn
        % Load the truth values
        Y=get_truth(data_dir, types{i});
        
        % Load the results
        Yhat=get_resu([resu_dir '/' filenames{k}], types{i});
        
        % Create a result object
        RCE=CEresult(Yhat, Y);
        
        % Compute various scores
        R.Dependency(k, i)=DEPscore(RCE, 0);
        R.Confounding(k, i)=DEPscore(RCE, 1);
        R.Causality(k, i)=CEscore(RCE, 0, 1);
        R.Score(k, i)=CEscore(RCE);
    end
end % End loop over result files

%% Save results
save(resu_filename, 'R');
print_resu(resu_filename, R);

% -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-
%
%                               SAMPLE CODE FOR THE
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

% Initialization
clear D TRAIN TEST VALID
try close(h); end
this_dir=pwd;

%%-o-|-o-|-o-|-o-|-o-|-o-|-o- BEGIN USER-PREFERENCES -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-

% 1) User-defined data path (no slash at end of dir names)
% --------------------------------------------------------
% The present set up supposes that you are now in the directory Sample_code
% and you have the following directory tree, where Challenge is you project directory:
% Challenge/Data
% Challenge/Results
% Challenge/Sample_code

my_root            = this_dir(1:end-5);               % Change that to the directory of your project
if ~exist(my_root, 'dir'), 
    fprintf('Please start in the Code/ directory');
end

public_data_dir    = [my_root '/CEdata/PUBLIC'];      % Path to the data.
private_data_dir   = '';                              % Path to hidden labels and info available only to organizer.
resu_dir           = [my_root '/Results'];            % Where the results will end up.  
code_dir           = [my_root '/Code'];               % Path to the code (this directory).

% Set name and data types (remove 'test', if test set not available)
my_name            = 'Isabelle Guyon';     % Your name or nickname
types              = {'train', 'valid', 'test'};

% 2) Choose your model
% -------------------------
model_list={@baseline, @CEmodel}; % baseline is a downsized simplified version of CEmodel
model_num=1;                % Number(s) of chosen model(s) in model_list
                            % (you can choose a subset in model_list, e.g. 1:3, [1, 3, 4])
% Set model options
% If you use CEmodel, you will have to choose among some options (those are hard coded in baseline):
model_options={'max_time=10', 'max_train_num=20', 'max_test_num=20', 'max_point_num=100', 'test_on_training_data=0', 'chosen_causa=1'};
% max_time --               Maximum time is seconds for each method
% max_train_num --          Limits the number of training examples (number of pairs) - 0 mean NO training
% max_test_num --           Limits the number of test examples (Inf=no limit)
% max_point_num --          Limits the number of points used for each pair
% test_on_training_data --  Tests the training examples with the trained
%                           model (because we only select a model in our model example, we get
%                           the results of the trained model even if test_on_training_data=0)
% chosen_causa --           Number of the chosen causality algorithm (1: igci, 2: anm, 3: lingam)
%                           If max_num_train>0, the method selects
%                           the best algorithm on training data and
%                           overwrites chosen_causa

% 3) Enable debug mode
% --------------------
debugme=0;                  % Level of verbosity: 0, 1, 2, 3... (0 for speed)

% 4) Save results
% ---------------
save_training_resu=0;       % Kaggle does not take training results
 
%% -o-|-o-|-o-|-o-|-o-|-o-|-o- END USER-PREFERENCES -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-


% Set path
set_path(code_dir); 

% Create result directory
makedir(resu_dir);

% Set verbosity level
if debugme
    model_options =[model_options sprintf('verbosity=%d', debugme)];
    dbstop if error
end

% Remove spaces
my_name(my_name==' ')='';

% Find data name (sample or CEdata)
dataname=find_name(public_data_dir);

%% Loop over models
for num=model_num
    mymodel=model_list{num};

    % Define experiment name
    starting_time=datestr(now, 'yyyy_mm_dd_HH_MM');
    experiment_name=[dataname '_' func2str(mymodel) '_' my_name '_' starting_time];

    % Train/Test
    fprintf('\n-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-\n');
    fprintf('\n-o-|-o-|     %s     |-o-|-o-\n', upper(experiment_name));
    fprintf('\n-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-\n\n');
    code_version;
    fprintf('\n== Legend ==\n');
    fprintf('Scores based on the AUC for the separation of class1 vs. class2\n');
    fprintf('- Depen=Dependency: class1=A|B, class2=[A->B, A<-B]\n');
    fprintf('- Causa=Causality: class1=A->B, class2=A<-B\n');
    fprintf('- Conf=Confounding: class1=A-B, class2=[A->B, A<-B]\n');
    fprintf('- CEscore= Challenge ranking score: Average score of {class1=A->B, class2=[A<-B, A-B, A|B]}\nand {class1=A<-B, class2=[A->B, A-B, A|B]} \n');
    fprintf('-- All scores are in percent (multipled by 100) --\n');
    
    fprintf('\n** BE PATIENT, determining causal orientation takes time!!!\n\n');
    
    fprintf('Subset\tDepen\tConf\tCausa\tCEscore\tTime (s)')
    T=length(types);
    Dependency=zeros(T,1);
    Causality=zeros(T,1);
    Confounding=zeros(T,1);
    Score=zeros(T,1);
    Time=zeros(T,1);

    % Loop over train, valid, and test sets
    for k=1:T
        % Load data
        if debugme, fprintf(2, '\nLoading %s set ... ', upper(types{k})); end
        D=CEdata(dataname, types{k}, public_data_dir, private_data_dir);
        if debugme, fprintf(2, ' %d samples loaded\n', length(D)); end

        % Uncomment this to browse the data
        % browse(D); 

        tic
        % Train a model
        if strcmp(types{k}, 'train')
            [Resu{k}, mymodel]=train(mymodel(model_options), D);
        else
            Resu{k}=test(mymodel, D);
        end

        Time(k)=toc;
        
        if ~isempty(Resu{k}.Y)
            % Scores just provided for information:
            Dependency(k)=DEPscore(Resu{k}, 0);
            Confounding(k)=DEPscore(Resu{k}, 1);
            Causality(k)=CEscore(Resu{k}, 0, 1);

            % Score according to which you will be ranked:
            Score(k)=CEscore(Resu{k}); 

            fprintf('\n%s\t', upper(types{k}));
            fprintf('%5.5f\t%5.5f\t%5.5f\t%5.5f\t', ...
                Dependency(k), ...
                Confounding(k), ...
                Causality(k), ...
                Score(k));
            fprintf('%5.2f', Time(k));          
        else
            fprintf('\n%s\tNo target values available\t%5.2f', upper(types{k}), Time(k));
        end

        % Save the results:
        if save_training_resu || ~strcmp(types{k}, 'train')
            R=Resu{k}; R.Y=[]; % Don't save the target values
            save(R, [resu_dir '/' experiment_name], types{k}, 'a');
        end
        % You will be judged only on the test set predictions
        % However, please also provide predictions on the validation set
        % with your final submission to help our analysis.
        % The Kaggle platform does not take training results.
    end
    fprintf('\n\n');
    show(mymodel);

end % End loop over models



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

my_root            = '../../';               % Change that to the directory of your project
if ~exist(my_root, 'dir'), 
    fprintf('Please start in the Code/ directory');
end

%public_data_dir    = [my_root 'matlab-code/CEdata_matlab/PUBLIC'];      % Path to the data.
public_data_dir    = [my_root 'Competition/'];      % Path to the data.
private_data_dir   = '';                              % Path to hidden labels and info available only to organizer.
resu_dir           = [my_root 'Models/Matlab'];            % Where the results will end up.  
code_dir           = [my_root 'matlab-code/Code'];               % Path to the code (this directory).

my_name            = 'Firfirikos';     % Your name or nickname

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

% Net parameters

ninputs =   size(trpattern,1); %3
nhidden =   12; %12 %% Must be even, since #hidden units for each g_i is nhidden/2.
% 12 in T_S, 10 in T_S_1
noutputs =  ninputs;
nextra = 4;  %%4

ntrain = length(trpattern); %1000
if ~Init_f
    initialepochs = 100;
else 
    initialepochs = 350; % 400 in T_S; 300 in T_S1
end
epochs_no_momentum = 150;

nepochs = 2000; %%2600 1600

ndisp = 50;
ndistr = 100;
ngrid = 21;

weightrange = 1;

wdecayf12 = 0; % .5;
wdecayf23 = 0; %.5;
wdecayf34 = 0;

eta0 = 1e-6;
eta013 = eta0;    % eta0 for weights between layers 1,2 and 3
up =  1.2;
down = 1/up;
tolerance = 1e-8;  % tolerance is additive because cost is logarithmic
reduce = down;
alpha = .99;

range = .5;
scalef = 2;
for i=1:ninputs
   dataf(i) = 3;
end

% withe regularization!
% lambda = 0.02 / (sum(diag(trpattern*trpattern'/ntrain))/ninputs); % lamda = 1/c %%% 0.05 %%%0.15
lambda = 0;

% lambda_in = 0.1; a = 3.7;

SE = [];
cost_2_back = [];

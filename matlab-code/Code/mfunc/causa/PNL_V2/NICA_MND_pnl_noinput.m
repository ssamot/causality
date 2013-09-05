function [y, net, SNR, fx1, fx2] = NICA_MND_pnl(x,s)
% Use of "Nonlinear ICA with MND for Matlab" for distinguishing cause from effect 
% Version 1.0, Aug. 15 2007
% PURPOSE:
%       Performing nonlinear ICA with the minimal nonlinear distortion or
%           smoothness regularization.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS:
%       x (n*T): a matrix containing multivariate observed data. Each row of the 
%           matrix x is a observed signal.
%   OPTIONAL INPUTS:
%       s (n*T): contains the original independent sources. If it is
%       provided, the SNR will be evaluated; otherwise SNR is empty.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OUTPUTS:
%       y (n*T): the separation result.
%       net: the structure specifying the separation MLP network. It
%           contains all weights and biase.
%       SNR (1*2n): The sigal-to-noise ratio of y, as well as that of
%           \tau(y) w.r.t. the original indepdnent sources.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% USAGE:
%       [y, net, SNR] = NICA_MND(x,s); or
%       [y, net, SNR] = NICA_MND(x);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Kun Zhang (Email: kzhang@cse.cuhk.edu.hk)
% This software is for non commercial use only. It is freeware but not in the public 
% domain.
% If you find any bugs, please report them to me. Thanks a lot!

%IG: set fp to 2 to see debug/progress messages
fp=0;

trpattern = x;
% % Thi is special for PNL acyclic causal discovery!!!!
trpattern = trpattern - repmat(mean(trpattern')', 1, length(trpattern));
trpattern = diag(1.5./std(trpattern')) * trpattern;

% network construction and settings
dprintf(fp, '***Input parameters to specify the separation MLP network***\n');
Init_f = 1; % learning f without tuning gives a good initialization
netpar_MND_pnl;
IF_direct = 1;

% % Now we use a special kind of DIRECT CONNECTIONS (for each network, only one is 1, and the others are 0)
% Direct_input = input('Are direct connections allowed? 1--yes; 0--no. (default: yes):\n');
% if ~isempty(Direct_input)
%     IF_direct = Direct_input;
% end

% % nhidden_input = input('Number of hidden units connected to each ouput (default: 10):\n');
% % if ~isempty(nhidden_input)
% %     nhidden = nhidden_input;
% % end
% % nepochs_input = input('Number of iterations (default: 1200):\n');
% % if ~isempty(nepochs_input)
% %     nepochs = nepochs_input;
% % end
% % lambda_input = input('The value of \lambda (default: 0.02):\n');
% % if ~isempty(lambda_input)
% %     lambda = lambda_input / (sum(diag(trpattern*trpattern'/ntrain))/ninputs);
% % end
lambda = 0;
% now no need to do linear initialization
Linear_init = 0; %???
% Linear_input = input('Initialize the network with linear ICA results? 1--yes; 0--no. (default: yes):\n');
% if ~isempty(Linear_input)
%     Linear_init = Linear_input;
% end

% netwoek initlization
netinit_MND_pnl;
% netinit_MND_pnl_Linit;

%network training
train_MND_lamdachange_pnl;

% creat y, net, and SNR
postprocessing_MND;

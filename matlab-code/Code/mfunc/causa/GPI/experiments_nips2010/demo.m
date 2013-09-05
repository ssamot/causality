% DEMO script, illustrating some of the functionality that comes
% with the GPI sofware implementation
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.
%


%1.  run startup code to include all paths
startup

%2. use the run_sim_cluster script to run a particular cluster
%result

%use only 100 points in the simulation to make this fast
N=100;

%run just a single experiment (somewhere between additive and
%multipicative noise)
run_sim_cluster(3,5,'amnoise',N);

%3. plot inference results
out_file = './out_sim_100_prior_eps=1e-03_jit=1e-05_lbar=1e+02_reg=1e-04/amnoise/sim_q1.00_alpha0.50_b1.00_jit1.00e-05_D1.mat';


load(out_file);

%4. plot fitted models:
figure(1);
plot_fitted_models(out_file);


%5. Difference of negative marginal likelihoods: 
disp(sprintf('Marginal likelihood X->Y %.2f',-INFO_XY.DL));
disp(sprintf('Marginal likelihood X->Y %.2f',-INFO_YX.DL));

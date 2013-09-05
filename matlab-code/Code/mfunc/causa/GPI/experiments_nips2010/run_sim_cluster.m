function run_sim_cluster(job,njobs,experiment,N)
% function run_sim_cluster(job,njobs,experiment)
%
% Cluster script for experiments with synthetic data
%
% INPUT:
%   job:        number of cluster run
%   njobs:      total number of cluster runs
%   experiment: experiment to run (should be one of
%   'amnoise','nongauss','nonlinear')
%   N:          number of points to simulate (default 500)
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.
%

  % set default number of data points
  if nargin < 4
    N = 500;
  end;

  % parameters that might need tuning
  CFG_XY = struct;
  CFG_XY.jitter = 1e-5;
  CFG_XY.epslabs = 1e-3;
  CFG_XY.priors = {[30,0.5], [30,0.5], [30,0.5]};
  CFG_XY.barrier = 1e2;
  CFG_X = struct;
  CFG_X.reg = 1e-4;

  % set default directory name for output
  if isfield(CFG_XY,'priors')
    out_base = sprintf('out_sim_%d_prior_eps=%.0e_jit=%.0e_lbar=%.0e_reg=%.0e',N,CFG_XY.epslabs,CFG_XY.jitter,CFG_XY.barrier,CFG_X.reg);
  else
    out_base = sprintf('out_sim_%d_noprior_eps=%.0e_jit=%.0e_lbar=%.0e_reg=%.0e',N,CFG_XY.epslabs,CFG_XY.jitter,CFG_XY.barrier,CFG_X.reg);
  end
  if isfield(CFG_XY,'uniform') && CFG_XY.uniform
    out_base = sprintf('%s_uniform',out_base);
  end
  if isfield(CFG_XY,'no_inf') && CFG_XY.no_inf
    out_base = sprintf('%s_noinf',out_base);
  end
  if isfield(CFG_XY,'scaleX')
    out_base = sprintf('%s_scaleX=%e',out_base,CFG_XY.scaleX);
  end
  if isfield(CFG_XY,'scaleY')
    out_base = sprintf('%s_scaleY=%e',out_base,CFG_XY.scaleY);
  end
  out_base = fullfile(out_base,experiment);

  % parameter ranges for different experiments
  switch experiment
    case {'amnoise'}
      parrange = linspace(0.0,1.0,5);
    case {'nongauss'}
      parrange = linspace(0.2,1.8,5);
    case {'nonlinear'}
      parrange = linspace(-1.0,1.0,5);
  end;

  % calculate indices from job indentifier
  nruns = njobs / length(parrange);
  srange = 1:nruns;
  [im, is] = ind2sub([length(parrange),length(srange)],job); % get index

  % set random number seeds
  ID = srange(is);  
  rand('seed',ID);
  randn('seed',ID);

  % set default parameters for experiments
  qX = 1;           % Gaussian input
  qE = 1;           % Gaussian noise
  b = 1;            % use non-linearity
  alpha = 0;        % additive noise

  % set parameters for different experiments
  switch experiment
    case {'amnoise'}
      alpha = parrange(im);
    
    case {'nongauss'}
      qE = parrange(im);  % non-Gaussian noise
      qX = qE;            % non-Gaussian input
      b = 0;              % linear
    
    case {'nonlinear'}
      b = parrange(im);

  end;

  % simulate data
  % sample input
  X = sample('nongauss',N,qX);
  X = sort(X);
  % sample noise
  Etrue = sample('nongauss',N,qE);
  EtrueM = alpha * Etrue;
  EtrueA = (1-alpha) * Etrue;
  f = (X + b * X.^3);
  Y = f .* exp(EtrueM) + EtrueA;
  Rtrue = Y-f;

  % save simulation
  SIM = struct;
  SIM.X = X;
  SIM.Y = Y;
  SIM.Etrue = Etrue;
  SIM.b = b;
  SIM.qE = qE;
  SIM.qX = qX;
  SIM.alpha = alpha;

  % make output directory
  if ~exist(out_base,'dir')
    mkdir(out_base);
  end;

  % check if output file already exists
  out_file = fullfile(out_base,sprintf('sim_q%.2f_alpha%.2f_b%.2f_jit%.2e_D%d.mat',qE,alpha,b,CFG_XY.jitter,ID));
  if exist(out_file,'file')
    % skip if file alrady exists
    fprintf('%s already exists! nothing left to do...\n', out_file);
  
  else
    % run GPI-MML
    [DL_XY,INFO_XY,INFO_X] = gpi_mml(X,Y,CFG_XY,CFG_X);
    [DL_YX,INFO_YX,INFO_Y] = gpi_mml(Y,X,CFG_XY,CFG_X);
    
    % run AN-HSIC and GPI-HSIC
    [INFO_XY.pHSIC_AN] = fasthsic(X,INFO_XY.GP.E);
    [INFO_XY.pHSIC] = fasthsic(X,INFO_XY.hyp.e);
    [INFO_YX.pHSIC_AN] = fasthsic(Y,INFO_YX.GP.E);
    [INFO_YX.pHSIC] = fasthsic(Y,INFO_YX.hyp.e);
    
    % save results
    save(out_file,'INFO_XY','INFO_YX','INFO_X','INFO_Y','CFG_XY','CFG_X','SIM','nruns');
    fprintf('Wrote output to %s\n',out_file);
  end;
return

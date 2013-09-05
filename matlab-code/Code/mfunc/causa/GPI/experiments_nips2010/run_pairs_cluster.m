function run_pairs_cluster(pair)
% function run_pairs_cluster(pair)
%
% Cluster script for experiments on cause-effect pairs
%
% INPUT:
%   pair: pair ID
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.
%


  % set maximum number of data points
  N = 500;

  %load pair
  preprocessing.maxN = N; % subsample maxN data points
  preprocessing.randseed = 37; % random number seed for subsampling
  [X,Y,weight] = load_pair(pair,preprocessing,'./../webdav');
  assert(size(X,2) == 1 && size(Y,2) == 1);

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
    out_base = sprintf('out_pairs_%d_prior_eps=%.0e_jit=%.0e_lbar=%.0e_reg=%.0e',N,CFG_XY.epslabs,CFG_XY.jitter,CFG_XY.barrier,CFG_X.reg);
  else
    out_base = sprintf('out_pairs_%d_noprior_eps=%.0e_jit=%.0e_lbar=%.0e_reg=%.0e',N,CFG_XY.epslabs,CFG_XY.jitter,CFG_XY.barrier,CFG_X.reg);
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

  % make output directory
  if ~exist(out_base,'dir')
    mkdir(out_base);
  end;

  % check if output file already exists
  out_file = fullfile(out_base,sprintf('pair_%d.mat',pair));
  if exist(out_file,'file')
    % skip if file alrady exists
    fprintf('%s already exists! Aborting...\n', out_file);
    exit(1);
  end;

  % run GPI-MML
  [DL_XY,INFO_XY,INFO_X] = gpi_mml(X,Y,CFG_XY,CFG_X);
  [DL_YX,INFO_YX,INFO_Y] = gpi_mml(Y,X,CFG_XY,CFG_X);

  % run AN-HSIC and GPI-HSIC
  [INFO_XY.pHSIC_AN] = fasthsic(X,INFO_XY.GP.E);
  [INFO_XY.pHSIC] = fasthsic(X,INFO_XY.hyp.e);
  [INFO_YX.pHSIC_AN] = fasthsic(Y,INFO_YX.GP.E);
  [INFO_YX.pHSIC] = fasthsic(Y,INFO_YX.hyp.e);

  %run LINGAM
  %CODE NOT INCLUDED
  %lingam = run_lingam(X,Y);

  %run PNL
  %CODE NOT INCLUDED
  %[pnl,PNL_XY,PNL_YX] = run_pnl(X,Y);

  % save results
  save(out_file,'INFO_XY','INFO_YX','INFO_X','INFO_Y','CFG_XY','CFG_X','weight');
  fprintf('Wrote output to %s\n',out_file);

return

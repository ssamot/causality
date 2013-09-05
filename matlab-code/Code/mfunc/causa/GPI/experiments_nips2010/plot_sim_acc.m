function [] = plot_sim_acc(out_base,save_fig,experiment)
% function [] = plot_sim_acc(out_base,save_fig,experiment)
%
% Plots results of simulations
%
% INPUT:
%   out_base:    base directory name
%   save_fig:    whether to save the plots to files (as EPS in out_base/figures) (default: false)
%   experiment:  one of 'amnoise', 'nongauss', 'nonlinear', 'jitter'
%                (if omitted, does all of them in sequence)
%
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.
%


  % set default input arguments
  if nargin<2
    save_fig=false;
  end

  % plot all experiments
  if nargin<3
    plot_sim_acc(out_base,save_fig,'amnoise');
    plot_sim_acc(out_base,save_fig,'nongauss');
    plot_sim_acc(out_base,save_fig,'nonlinear');
    plot_sim_acc(out_base,save_fig,'legend');
    return
  end;

  % generate path names
  fig_out_path = fullfile(out_base,'figures');
  out_path = fullfile(out_base,experiment);

  % set default parameters for experiments
  qX = 1;           % Gaussian input
  qE = 1;           % Gaussian noise
  b = 1;            % use non-linearity
  alpha = 0;        % additive noise

  % load experimental results
  switch experiment
    case {'amnoise'}
      Xrange = linspace(0.0,1.0,5);
      for im=1:length(Xrange)
        alpha = Xrange(im);
        flist = sprintf('sim_q%.2f_alpha%.2f_b%.2f*.mat',qE,alpha,b);
        [sc(im),ok(im),sf(im)] = load_result_dir(out_path,flist);
      end 
      xlabel_str = '\alpha';
    
    case {'nongauss'}
      Xrange = linspace(0.2,1.8,5);
      b = 0.0;
      for im=1:length(Xrange)
        qE = Xrange(im);
        qX = Xrange(im);
        flist = sprintf('sim_q%.2f_alpha%.2f_b%.2f*.mat',qE,alpha,b);
        [sc(im),ok(im),sf(im)] = load_result_dir(out_path,flist);
      end 
      xlabel_str = 'q';
      
    case {'nonlinear'}
      Xrange = linspace(-1.0,1.0,5);
      for im=1:length(Xrange)
        b = Xrange(im);
        flist = sprintf('sim_q%.2f_alpha%.2f_b%.2f*.mat',qE,alpha,b);
        [sc(im),ok(im),sf(im)] = load_result_dir(out_path,flist);
      end 
      xlabel_str = 'b'; 

    case {'legend'}
      Xrange = [0];
      sc.AN_DL = [0];
      sc.AN_HSIC = [0];
      sc.AN_GAUSS = [0];
      sc.GPI_DL = [0];
      sc.GPI_HSIC = [0];
      sc.IGCI = [0];
  end;

  % plot results
  figure;
  if strcmp(experiment,'legend')
    axis off;
  end
  hold on;
  p1 = plot(Xrange,[sc(:).AN_DL],'r-');
  p2 = plot(Xrange,[sc(:).AN_HSIC],'r--');
  p3 = plot(Xrange,[sc(:).AN_GAUSS],'r:');
  p4 = plot(Xrange,[sc(:).GPI_DL],'k-');
  p5 = plot(Xrange,[sc(:).GPI_HSIC],'k--');
  p6 = plot(Xrange,[sc(:).IGCI],'g-');
  if strcmp(experiment,'legend')
    xlim([-200,100]);
    ylim([-100,100]);
    legend([p1,p2,p3,p4,p5,p6],'AN-MML','AN-HSIC','AN-GAUSS','GPI-MML','GPI-HSIC','IGCI');
    L=get(legend);
    L.Position(1) = 0.5 * (1 - L.Position(3));
    L.Position(2) = 0.5 * (1 - L.Position(4));
    L.OuterPosition(1) = 0.5 * (1 - L.OuterPosition(3));
    L.OuterPosition(2) = 0.5 * (1 - L.OuterPosition(4));
    set(legend,'Position',L.Position);
    set(legend,'OuterPosition',L.OuterPosition);
    axis off;
  else
    ylabel('Accuracy');
    xlabel(xlabel_str);
    ylim([0,1]);
  end

  % save results, if requested
  if save_fig
    if ~exist(fig_out_path,'dir')
      mkdir(fig_out_path);
    end
    exportfig(gcf,sprintf('%s/acc_%s.eps',fig_out_path,experiment),'width',5,'height',3,'FontMode','fixed','FontSize',14,'LineMode','fixed','LineWidth',2,'Color','rgb','Bounds','tight');
  end;
  if ~strcmp(experiment,'legend')
    title(experiment);
  end


return

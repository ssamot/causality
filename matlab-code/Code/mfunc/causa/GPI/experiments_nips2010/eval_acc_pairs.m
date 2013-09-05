function eval_acc_pairs(dir_name,fselect)
% function eval_acc_pairs(dir_name,fselect)
%
% INPUT:
%   dir_name:    directory containing the files
%   fselect:     mask for selecting files
%
% Evaluates the accuracy on the pairs dataset and outputs the
% results
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.
%


  % read file list
  if nargin < 2
    fselect = '*.mat';
  end
  flist = dir(fullfile(dir_name,fselect));
  fprintf('Found %d matching files.\n',length(flist));
  assert(length(flist)~=0);

  % read files
  R = struct();
  for il=1:length(flist)
    file_name = fullfile(dir_name,flist(il).name);
    ri = load(file_name);
    R(il).INFO_XY = ri.INFO_XY;
    R(il).INFO_YX = ri.INFO_YX;
    R(il).INFO_X = ri.INFO_X;
    R(il).INFO_Y = ri.INFO_Y;
    if isfield(ri,'lingam')
      R(il).lingam = ri.lingam;
    else
      R(il).lingam = nan;
    end
    if isfield(ri,'pnl')
      R(il).pnl = ri.pnl;
    else
      R(il).pnl = nan;
    end
    R(il).weight  = ri.weight;
  end;

  % get interesting data
  INFO_XY = [R(:).INFO_XY];
  INFO_YX = [R(:).INFO_YX];
  INFO_X = [R(:).INFO_X];
  INFO_Y = [R(:).INFO_Y];
  lingam = [R(:).lingam];
  pnl = [R(:).pnl];
  weights = [R(:).weight];
  nruns_success = length(INFO_XY);

  % calculate scores for each run
  for i=1:nruns_success
    X = INFO_XY(i).X; Y = INFO_XY(i).Y;

    % total description length
    DL_XY(i) = INFO_XY(i).DL + INFO_X(i).DL;
    DL_YX(i) = INFO_YX(i).DL + INFO_Y(i).DL;

    % scores: positive means X->Y
    San_hsic(i)   = log(INFO_XY(i).pHSIC_AN) - log(INFO_YX(i).pHSIC_AN);
    Sgpi_hsic(i)  = log(INFO_XY(i).pHSIC) - log(INFO_YX(i).pHSIC);
    San_dl(i)     = -(INFO_XY(i).GP.lml + INFO_X(i).DL - (INFO_YX(i).GP.lml + INFO_Y(i).DL));
    Sgpi_dl(i)    = -(DL_XY(i) - DL_YX(i));
    Sgpi_dlnop(i) = -((DL_XY(i) - sum(INFO_XY(i).cost.prior)) - (DL_YX(i) - sum(INFO_YX(i).cost.prior)));
    Suai_ent(i)   = ent(INFO_XY(i).X) - ent(INFO_YX(i).X);
    Suai_mml(i)   = INFO_X(i).DL - INFO_Y(i).DL;
    Slingam(i)    = lingam(i);
    Spnl(i)       = pnl(i);
    Sigci(i)      = -igci(X,Y,1,2);

    % for Friedman/Nachman:
    hyp.cov=-50;hyp.lik=log(std(X));lml_gaussX=gp(hyp,'infExact','meanZero','covConst','likGauss',zeros(size(X)),X);
    hyp.cov=-50;hyp.lik=log(std(Y));lml_gaussY=gp(hyp,'infExact','meanZero','covConst','likGauss',zeros(size(Y)),Y);
    San_gauss(i) = -((INFO_XY(i).GP.lml + lml_gaussX) - (INFO_YX(i).GP.lml + lml_gaussY));
    
    % count signflips in dfes
    X_dfe = INFO_XY(i).dfe;
    Y_dfe = INFO_YX(i).dfe;
    signflip(i) = ~((sign(max(X_dfe)) == sign(min(X_dfe))) && (sign(max(Y_dfe)) == sign(min(Y_dfe))));
  end;

  % calculated weighted averages
  Z = sum(weights);
  Ian_dl = sum((San_dl > 0) .* weights) / Z;
  Ian_hsic = sum((San_hsic > 0) .* weights) / Z;
  Ian_gauss = sum((San_gauss > 0) .* weights) / Z;
  Igpi_dl = sum((Sgpi_dl > 0) .* weights) / Z;
  Igpi_dlnop = sum((Sgpi_dlnop > 0) .* weights) / Z;
  Igpi_hsic = sum((Sgpi_hsic > 0) .* weights) / Z;
  Iuai_ent = sum((Suai_ent > 0) .* weights) / Z;
  Iuai_mml = sum((Suai_mml > 0) .* weights) / Z;
  Iigci = sum((Sigci > 0) .* weights) / Z;
  Ilingam = sum((Slingam > 0) .* weights) / Z;
  Ipnl = sum((Spnl > 0) .* weights) / Z;
  Isf = sum(signflip .* weights) / Z;

  % output results
  fprintf('total weight: %f\n',Z);
  fprintf('AN DL:      %.2f\n',Ian_dl);
  fprintf('AN HSIC:    %.2f\n',Ian_hsic);
  fprintf('AN GAUSS:   %.2f\n',Ian_gauss);
  fprintf('GPI DL:     %.2f\n',Igpi_dl);
  fprintf('GPI DL nop: %.2f\n',Igpi_dlnop);
  fprintf('GPI HSIC:   %.2f\n',Igpi_hsic);
  fprintf('UAI ent:    %.2f\n',Iuai_ent);
  fprintf('UAI MML:    %.2f\n',Iuai_mml);
  fprintf('IGCI:       %.2f\n',Iigci);
%  fprintf('LINGAM:     %.2f\n',Ilingam);
%  fprintf('PNL:        %.2f\n',Ipnl);
  fprintf('signflips:  %.2f\n',Isf);

return

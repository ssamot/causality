function [scores,ok,signflips,DLdiff] = load_result_dir(dir_name,fselect)
% function [scores,ok,signflips,DLdiff] = load_result_dir(dir_name,fselect)
%
% INPUT:
%   dir_name:    directory containing the files
%   fselect:     mask for selecting files
%
% OUTPUT:
%   scores:      percentage of correct decisions for various methods
%     .AN_DL       additive noise / description length
%     .AN_HSIC     additive noise / HSIC
%     .AN_GAUSS    additive noise / Gaussian input (Friedman/Nachman style)
%     .GPI_DL      GPI / description length
%     .GPI_DLnop   GPI / description length, no prior in cost function
%     .GPI_HSIC    GPI / HSIC
%     .UAI         UAI method
%     .IGCI        UAI method with Povilas' estimator
%   ok:          percentage of runs that successfully completed
%   signflips:   percentage of runs with sign flips in dfe
%   DLdiff:      vector with differences of DL's
%     .AN:         for additive noise
%     .GPI:        for GPI
%     .GPInop:     for GPI, no prior in cost function
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.
%


  % read file list
  flist = dir(fullfile(dir_name,fselect));
  fprintf('Found %d matching files.\n',length(flist));
  if length(flist) == 0
    fprintf('fselect: %s  dir_name: %s\n',fselect,dir_name);
    scores.AN_DL = nan;
    scores.AN_HSIC = nan;
    scores.AN_GAUSS = nan;
    scores.GPI_DL = nan;
    scores.GPI_DLnop = nan;
    scores.GPI_HSIC = nan;
    scores.UAI = nan;
    scores.IGCI = nan;
    ok = 0;
    signflips = nan;
    DLdiff.AN = nan;
    DLdiff.GPI = nan;
    DLdiff.GPInop = nan;
    return
  end

  % read files
  R = struct();
  for il=1:length(flist)
    file_name = fullfile(dir_name,flist(il).name);
    ri = load(file_name);
    nruns = ri.nruns;
    R(il).INFO_XY = ri.INFO_XY;
    R(il).INFO_YX = ri.INFO_YX;
    R(il).INFO_X = ri.INFO_X;
    R(il).INFO_Y = ri.INFO_Y;
  end;

  % get interesting data
  INFO_XY = [R(:).INFO_XY];
  INFO_YX = [R(:).INFO_YX];
  INFO_X = [R(:).INFO_X];
  INFO_Y = [R(:).INFO_Y];
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
    Suai(i)       = ent(INFO_XY(i).X) - ent(INFO_YX(i).X);
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
  scores.AN_DL = mean(San_dl > 0);
  scores.AN_HSIC = mean(San_hsic > 0);
  scores.AN_GAUSS = mean(San_gauss > 0);
  scores.GPI_DL = mean(Sgpi_dl > 0);
  scores.GPI_DLnop = mean(Sgpi_dlnop > 0);
  scores.GPI_HSIC = mean(Sgpi_hsic > 0);
  scores.UAI = mean(Suai > 0);
  scores.IGCI = mean(Sigci > 0);
  ok = nruns_success / nruns;
  signflips = mean(signflip);
  DLdiff.AN = San_dl;
  DLdiff.GPI = Sgpi_dl;
  DLdiff.GPInop = Sgpi_dlnop;

return

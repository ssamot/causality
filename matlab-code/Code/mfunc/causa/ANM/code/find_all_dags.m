function find_all_dags(X,alpha,k,doregressions,regfile,outfile)
% function find_all_dags(X,alpha,k,doregressions,regfile,outfile)
%
% Assuming that the data is described by a multivariate additive noise
% model, finds all (minimal) DAGs that are consistent with the data by
% brute-force enumeration. Only outputs the k best DAGs.
%
% INPUT:  X              should be N*d matrix (N = number of data points,
%                        d = number of variables);
%         alpha          threshold for each independence test (e.g., 0.05);
%                        if alpha == 0.0 then calculate score of model obtained by
%                        multiplying the p-values together, and reject the DAG if
%                        the resulting score == 0.0;
%         k              size of list of DAGs with best scores (e.g., 10000);
%         doregressions  if == 0: load the regression results from regfile (fast),
%                        if ~= 0: do the regressions and save the results to regfile;
%         regfile        filename for regression results (will be MatLab format)
%         outfile        filename to which the toplist will be written.
%
% OUTPUT: written to file named outfile (in ASCII format)
%
% NOTE:   uses testalldags MEX file
%
% Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

  d = size(X,2);

  if doregressions~=0
    % assume: data is in X, normalize it
    for i = 1:d
      X(:,i) = normalize(X(:,i));
    end

    % calculate all possible regression residuals
    res = zeros(size(X,1),d*2^d);
    for i=1:d
      fprintf('Variable %d out of %d...\n',i,d);
      for pabit = 0:(2^d-1)
        parents = n2set(pabit)
        if ~bitget(pabit,i)
          res(:,(i-1)*2^d+pabit+1) = X(:,i) - fit_gp(X(:,parents),X(:,i));
        end
      end
    end

    % save residuals to file
    save(regfile,'res','X');
  else
    load(regfile);
  end

  % get all minimal DAGs that are consistent with the data
  testalldags( d, res, alpha, k, outfile )

return


function set = n2set(n)
% function set = n2set(n)
%
% Decodes an integer into a set
  set = [];
  for i=1:32
    if bitget(n,1) == 1
      set = [set i];
    end
    n = bitshift(n,-1);
  end
return


function n = set2n(set)
% function n = set2n(set)
%
% Encodes a set into an integer
  n = sum(2.^(set-1));
return


function Z = normalize(X)
% function Z = normalize(X)
%
% Returns a normalized version of X:
% each column is scaled and shifted such that it has mean 0 and variance 1
  Z = (X - ones(size(X,1),1) * mean(X)) ./ (ones(size(X,1),1) * std(X));
return

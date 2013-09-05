% Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.
%
% Diamond example: goes through all DAGs and checks consistency with data
% (and throws away superDAGS)

fprintf('----------\n');
fprintf('Doing DAG experiment...\n\n');

try
  D = load('-ascii','../fig/exp_multi.dat');
catch
  N = 500;
  rand('twister',5489);
  eps1 = rand(N,1)*2-1;
  eps2 = rand(N,1)*2-1;
  eps3 = rand(N,1)*2-1;

  W = rand(N,1)*6 - 3;
  X = W.^2 + eps1;
  Y = 4 * sqrt(abs(W)) + eps2;
  Z = 2 * sin(X) + 2 * sin(Y) + eps3;

  D = [W X Y Z];

  save('-ascii','../fig/exp_multi.dat','D');
end

format long e

regressions_exist = 0;
try
  tmp = load('../fig/exp_multi.mat');
  regressions_exist = 1;
  clear tmp
catch
  regressions_exist = 0;
end

if regressions_exist
  find_all_dags(D,0.02,1000,0,'../fig/exp_multi.mat','../fig/exp_multi.out');
else
  find_all_dags(D,0.02,1000,1,'../fig/exp_multi.mat','../fig/exp_multi.out');
end

system('./gvtoplist ../fig/exp_multi.out');

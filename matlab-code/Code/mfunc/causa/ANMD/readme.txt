This package contains code to the paper
Jonas Peters, Dominik Janzing, Bernhard Schoelkopf (2010): Identifying Cause and Effect on Discrete Data using Additive Noise Models, in Y.W. Teh and M. Titterington (Eds.), Proceedings of The Thirteenth International Conference on Artificial Intelligence and Statistics (AISTATS) 2010, JMLR: W&CP 9, pp 597-604, Chia Laguna, Sardinia, Italy, May 13-15, 2010,
 
It is written in Matlab and should work on any machine. Some files (only for data simulation) require Matlab's Statistics Toolbox.


%%%%%%%%%%%%%
IMPORTANT FUNCTIONS
%%%%%%%%%%%%%
The function
    fit_both_dir_discrete.m
needs data as input (and the information, whether this data is cyclic) and fits a discrete additive noise model (ANM) in both directions. It outputs, whether the ANM method described in the paper, infers
X->Y,
Y->X,
"I do not know (bad model fit)" or
"I do not know (both directions possible)."
The functions
    add_noise.m
    add_noise_cyclic.m
can simulate data from discrete additive noise models. The three functions contain more information of how to use them. If you want to simulate drom standard distributions, Matlab's Statistical Toolbox is required.


%%%%%%%%%%%%%
EXAMPLE
%%%%%%%%%%%%%
As a first example type

pars.p_X=[0.1 0.3 0.1 0.1 0.2 0.1 0.1];pars.X_values=[-3;-2;-1;0;1;3;4];
pars2.p_n=[0.2 0.5 0.3];pars2.n_values=[-1;0;1];
[X Y]=add_noise(500,@(x) round(0.5*x.^2),'custom',pars,'custom',pars2, 'fct');
[fct1 p_val1 fct2 p_val2]=fit_both_dir_discrete(X,0,Y,0,0.05,0);

into Matlab.


%%%%%%%%%%%%%
REPRODUCING FIGURES
%%%%%%%%%%%%%
Note: 
-In the aistats paper there are only the "a" versions of Data Sets 1 - 3, and the "a" is omitted.
-Usually more information can be found in the files
 
exp1a.m (matlab's statistics toolbox needed!!!) produces the results of Data Set 1a, 
exp1b.m produces the results of Data Set 1b, 
exp2a.m produces the plot of Data Set 2a,
exp2b1.m and exp2b2.m produce the plots of Data Set 2b,
exp3a.m produces the results of Data Set 3a,
exp3b.m produces the results of Data Set 3b,
exp4.m produces the results of Data Set 4 and
exp5.m produces the plot of Data Set 5.


%%%%%%%%%%%%%
CITATION
%%%%%%%%%%%%%
If you use this code, please cite the following paper: 
Jonas Peters, Dominik Janzing, Bernhard Schoelkopf (2010): Identifying Cause and Effect on Discrete Data using Additive Noise Models, in Y.W. Teh and M. Titterington (Eds.), Proceedings of The Thirteenth International Conference on Artificial Intelligence and Statistics (AISTATS) 2010, JMLR: W&CP 9, pp 597-604, Chia Laguna, Sardinia, Italy, May 13-15, 2010,


%%%%%%%%%%%%%
LICENSE
%%%%%%%%%%%%%
asdasd


%%%%%%%%%%%%%
PROBLEMS
%%%%%%%%%%%%%
If you have problems or questions, do not hesitate to send me an email:
jonas.peters ---at--- tuebingen.mpg.de



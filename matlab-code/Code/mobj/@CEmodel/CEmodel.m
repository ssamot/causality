%==========================================================================
% CEmodel Cause-effect pair model object to recognize A->B from A<-B             
%==========================================================================
% a=CEmodel(hyper) 
%
% This is an object similar to a Spider object
% http://www.kyb.mpg.de/bs/people/spider/
%
% This object could be chained with other models (no example provided yet).
%
% All recognizers (called "model") must have at least 2 methods: train and test
% [resu, model]=train(model, data)
% resu = test(model, data)

%Isabelle Guyon -- isabelle@clopinet.com -- February 2013

classdef CEmodel
	properties (SetAccess = public)
        % 1) Choice of methods to test A | B (larger score means dependence)
        indep_tests={@correl, @hsic};    
        % 2) Choice of methods to test causal orientation. 
        % A positive score means A -> B, a negative score A <- B. 
        % A zero score means A <- Z -> B of that the causal orientation 
        % cannot be identified.
        % - igci is fast: linear in num points 0.001+4e-7N, can handle 10^6 points
        % - pnl is slow but linesr in num points 20+0.78N
        % - gpi is also slow but it maxes out at 51 sec at ~100 points (some subsampling
        % - anm is pretty fast (but quadratic in number of points 1e-4N^2);
        % do not exceed 600 points!
        % - anmd is fast (but quadratic in number of points 2e-6N^2)
        % - lingam is fast 0.02+3e-6N, no pb for 10000 points
        causa_tests={}; % See the constructor
        % Training consists in choosing methods.
        chosen_indep=1;
        chosen_causa=1;
        max_time=1;               % Maximum time in seconds per method
        max_train_num=Inf;        % Maximum number of training examples (for speed reason)
        max_test_num=Inf;         % Maximum number of test examples
        max_point_num=100;        % Maximum number of points in each pair (for speed reason)
        verbosity=0;              % Flag to turn on verbose mode for debug
        test_on_training_data=0;  % Flag to turn on training data
    end
    properties (SetAccess = private)
        causa_scores=[];          % Scores (success) of the causal tests
        indep_scores=[];          % Scores (success) of the indep tests
    end
    methods
        %%%%%%%%%%%%%%%%%%%
        %%% CONSTRUCTOR %%%
        %%%%%%%%%%%%%%%%%%%
        function a = CEmodel(hyper) 
            % More models work under MacOS and Linux
            if strfind(computer, 'PCWIN'), 
                a.causa_tests={@igci, @pnl};
            else
                a.causa_tests={@igci, @pnl, @lingam, @anm, @anmd, @gpi};
            end
            % Windows: @lingam, @anm, @anmd, and @gpi dont' work.
            % @anm requires the GSL library. It causes Matlab to crash if not
            % installed properly. 
            % The methods @pnl, is really slow  but works.
            
            % Evaluate hyper-parameters entered with the syntax of the
            % Spider http://www.kyb.mpg.de/bs/people/spider/
            eval_hyper;
        end  
        
        function score = exec(this, pair)
            %score = exec(this, pattern)
            % Compute output score for a single pattern
            snum=length(pair);
            rp=randperm(snum);
            snum=min(snum, this.max_point_num);
            pair=subset(pair, rp(1:snum));
            Dependency=this.indep_tests{this.chosen_indep}(get_A(pair), get_B(pair));
            Causality=this.causa_tests{this.chosen_causa}(get_A(pair), get_B(pair));
            score=Dependency*Causality;
            if isnan(score), score=0; end
        end
        
        function show(this)
            %show(this)
            fprintf('\tDependency: %s, Causality: %s\n', ...
                upper(func2str(this.indep_tests{this.chosen_indep})), ...
                upper(func2str(this.causa_tests{this.chosen_causa})));
        end
        
    end %methods
end %classdef
  

 

 
 






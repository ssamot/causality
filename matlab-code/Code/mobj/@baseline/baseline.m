%==========================================================================
% baseline method to distinguish A->B from A<-B             
%==========================================================================
% a=baseline(hyper) 
%
% This is a simple downsized vesion of CEmodel
% most of the options of CEmodel are turned off for this simple example
%
% CEmodel's must have at least 2 methods: train and test
% [resu, model]=train(model, data)
% resu = test(model, data)

%Isabelle Guyon -- isabelle@clopinet.com -- April 2013

classdef baseline < CEmodel % We make this class a child of CEmodel 

    methods
        %%%%%%%%%%%%%%%%%%%
        %%% CONSTRUCTOR %%%
        %%%%%%%%%%%%%%%%%%%
        function a = baseline(hyper) 
            % 1) Methods to test A | B (larger score means dependence)
            a.indep_tests={@hsic};    % There are other indepence tests, see Code/mfunc/indep
                     % this one is pretty good for continuous
                     % numerical variables. You may want to treat categorical
                     % variables differently
            
            % 2) Methods to test A -> B vs A <- B (return a value positive in the first
            % case and negative in the second case)
            a.causa_tests={@igci};    % This is a relatively fast method that works 
                     % pretty well (though I don't think it treats
                     % the case of categorical variables). The full blown
                     % CEmodel object chooses between alternative
                     % methods found in Code/mfunc/causa
                     
            % 3) Hyperparameters and options.
            % There are no hyper-parameters for training because there is no
            % training. See CEmodel that performs at least model selection.
            a.max_point_num=200;        % Maximum number of points in each pair (for speed reason)
            
            % 4) Evaluate hyper-parameters entered with the syntax of the
            % Spider http://www.kyb.mpg.de/bs/people/spider/
            % This will overwrite the above default values
            % We turned that off so the default cannot be
             % overwritten by accident (which could cause igci to become
            % REALLY slow...
            %eval_hyper; 
        end  
        
        function score = exec(this, pair)
            %score = exec(this, pattern)
            % Compute output score for a single pair
            
            % IMPORTANT: we used to pick examples at random rather that
            % taking the first few points. There is a drawback: we get
            % different results every time, hence the results are not
            % reproducible. If you use random subsets, make sure the same
            % subsets will always be chosen at every run of the code.
            snum=min(length(pair), this.max_point_num);
            pair=subset(pair, 1:snum);
            Dependency=this.indep_tests{1}(get_A(pair), get_B(pair));
            Causality=this.causa_tests{1}(get_A(pair), get_B(pair));
            score=Dependency*Causality;
            if isnan(score), score=0; end
        end
        
        function [myresu, this]=train(this, mydata)
            %[myresu, this]=train(mymodel, mydata)
            % This is a place holder, no training is performed.
            % Inputs:
            % this     -- A recognizer object.
            % mydata   -- A data object.
            %
            % Returns:
            % mymodel  -- The trained model.
            % myresu   -- A new data structure containing the results.
            
            % Just test the training examples, no training or adjustment of
            % hyper-parameters. See CEmodel for a fancier "train" function
            myresu=test(this, mydata);
        end
        
        function resu = test(this, mydata)
            %resu = test(this, mydata)
            % Make predictions with indep_test and causa_test.
            % Inputs:
            % model -- A recog_template object.
            % data -- A data structure.
            % Returns:
            % resu -- A result data structure. WARNING: this follows the convention of
            % Spider http://www.kyb.mpg.de/bs/people/spider/ *** The result is in resu.X!!!! ***
            % resu.Y are the target values.
            
            warning off % icgi issues some warnings when it fails
            P=length(mydata); 
            V=zeros(P, 1);
            for k=1:P
                % Monitor progress (this is important for slow algorithms)
                if this.verbosity>0 && ~mod(k, round(P/10))
                    fprintf('%d%% ', round(k/P*100));
                end
                % Compute the recognition results
                pair=get_X(mydata, k);
                V(k)=exec(this, pair);
            end
            warning on

            % Save the results
            Y = [get_Y(mydata), get_YT(mydata)]; % Target values
            resu = CEresult(V, Y);

            if this.verbosity>0, fprintf('\n==TE> Done testing %s... ', class(this)); end
        end
        
    end %methods
end %classdef
  

 

 
 






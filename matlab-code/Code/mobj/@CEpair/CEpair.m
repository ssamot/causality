%=============================================================================
% CEpair structure             
%=============================================================================  
% D=CEpair(A, B, CA, CB, FA, FB)
% D=CEpair(CEpair_obj)
% D=CEpair(filename) 
% 
% Creates a data structure for cause-effect pairs {A, B}.
% A and B must be column vactors.
%
% A CE pair is constructed from a pair of variables A and B, another
% CEpair, or a file name pointing to a file containing 2 variable in column.
% CA and CB indicate the type (category) of variable considered:
% 'Numerical', 'Binary', or 'Categorical'
% By default, variables are considered 'Numerical'.
% 'Numerical' means continuous discrete or ordinal
% 'Categorical' means nominal (the numbers represent categories or names).
% FA and FB optionally indicate the name of the variable (feature).
%
% Example:
% A=randn(100,1);
% B=A.^2+randn(100,1);
% AB=CEpair(A, B);
% plot(AB);
% fprintf('Indep (higher means more dependency): %g\n', indep(AB));
% fprintf('Causa (positive if A->B, negative if A<-B): %g\n', causa(AB));

%==========================================================================
% Author of code: Isabelle Guyon -- isabelle@clopinet.com -- Feb 2013
%==========================================================================

classdef CEpair < handle
    properties (SetAccess = public)
        A=[]; % Holds the A variable
        B=[]; % Holds the B variable
    end
    properties (SetAccess = private)
        CA='Numerical'; % Type of variable A ('Numerical', 'Binary', or 'Categorical')
        CB='Numerical'; % Type of variable B
        FA='A'; % Name of variable A 
        FB='B'; % Name of variable B
        subidx=[]; %subset of values to work on
        indep_test=@correl; % Try: @correl, @hsic 
        % correl is fast: linear in num points 0.001+9e-8N, can handle 10^6 points
        % hsic is CUBIC time in num points 6e-10N^3; there is also a
        % memory problem: Do NOT use with more than 4000 points!
        % todo: must compile fasthsic
        causa_test=@igci; % Try: @igci, @pnl, @lingam , @gpi, @anm, @anmd
        % igci is fast: linear in num points 0.001+4e-7N, can handle 10^6 points
        % pnl is slow but linesr in num points 20+0.78N
        % gpi is also slow but it maxes out at 51 sec at ~100 points (some subsampling
        % anm is pretty fast (but quadratic in number of points 1e-4N^2);
        % do not exceed 600 points!
        % anmd is fast (but quadratic in number of points 2e-6N^2)
        % lingam is fast 0.02+3e-6N, no pb for 10000 points
    end
    methods
        %%%%%%%%%%%%%%%%%%%
        %%% CONSTRUCTOR %%%
        %%%%%%%%%%%%%%%%%%%
        function this = CEpair(A, B, CA, CB, FA, FB) 
            %this = CEpair(A, B, CA, CB, FA, FB) 
            %this = CEpair(CEpair_obj) 
            %this = CEpair(filename) 
            if nargin<1, return; end
            if nargin<3 || isempty(CA), CA='Numerical'; CB='Numerical'; end;
            if nargin<5 || isempty(FA), FA='A'; FB='B'; end
            if ischar(A) 
                load(this, A);
            elseif isa(A, 'CEpair')
                % Create a copy
                this.A=A.A;
                this.B=A.B;
                this.CA=A.CA;
                this.CB=A.CB;
                this.FA=A.FA;
                this.FB=A.FB;
                this.subidx=A.subidx;
            else
                 % Make the variables column vectors
                A=reshape(A,[numel(A) 1]);
                B=reshape(B,[numel(B) 1]);
                n=length(A);
                if length(B)~=n, error('Incompatible pair length'); end
                this.A=A;
                this.B=B;
                this.CA=CA;
                this.CB=CB;
                this.FA=FA;
                this.FB=FB;
                this.subidx=1:n;
            end
        end          
        
        function D = subset(this, idx)
            %D = subset(this, idx)
            % Select a data subset
            % If the argument idx is not specified, all values are used.
            if nargin<2, idx=1:length(this.A); end
            D=CEpair(this);
            idx=setdiff(idx, find(idx>length(this.A))); 
            D.subidx=idx;
        end 
        
        function A=get_A(this, num)
            %A=get_A(this, num)
            if nargin<2
                num=this.subidx;
            else
                num=this.subidx(num);
            end
            if length(num)==1 && (num<1 || num>length(this.A)), A=[]; return; end
            A=this.A(num,:);
        end
        
        function B=get_B(this, num)
            %B=get_B(this, num)
            if nargin<2
                num=this.subidx;
            else
                num=this.subidx(num);
            end
            if length(num)==1 && (num<1 || num>length(this.A)), A=[]; return; end
            B=this.B(num,:);
        end
        
        function set_A(this, num, val)
            %set_A(this, num, val)
            num=this.subidx(num);
            this.A(num)=val;
        end
        
        function set_B(this, num, val)
            %set_B(this, num, val)
            num=this.subidx(num);
            this.B(num)=val;
        end  
        
        function n=length(this)
            %n=length(this)
            % number of samples
            n=length(this.subidx);
        end
        
        function plot(this, h)
            %plot(this, h)
            % Plot B against A
            if nargin<2, h=figure; else figure(h); end
            A=get_A(this);
            B=get_B(this);
            plot(A, B, '.', 'Markersize', 20);
            l1=this.FA; l1(l1=='_')=' '; l1=[l1 ' (' this.CA ')'];
            l2=this.FB; l2(l2=='_')=' '; l2=[l2 ' (' this.CB ')'];
            xlabel(l1, 'FontSize', 18); ylabel(l2, 'FontSize', 18);
        end % plot
        
        function show(this, h)
            %plot(this, h)
            % Plot B against A
            if nargin<2, h=figure; else figure(h); end
            plot(this, h);
        end % show
        
        function load(this, filename)
            %load(this, filename)
            % Load a pair from a file in MPI format
            X=load(filename);
            this.A=X(:,1);
            this.B=X(:,2);
            n=length(this.A);
            this.subidx=1:n;
        end % load
        
        function [tstat, pval]=indep(this)
            %[tstat, pval]=indep(this)
            % Statistical independence test. H0: A and B are independent.
            % The test statistic tstat is like an absolute "correlation"
            % it increases with dependency. Small pvalues shed doubt on H0.
            % i.e. dependent variables have small pvalues.
            A=get_A(this);
            B=get_B(this);
            [tstat, pval]=this.indep_test(A, B);
        end
        
        function direction=causa(this)
            %direction=causa(this)
            % Test of causal orientation.
            % direction >0 means A->B
            % direction <0 means B->A
            A=get_A(this);
            B=get_B(this);
            direction=this.causa_test(A, B);
        end
        
        function set(this, property, value)
            %set(this, property, value)
            % Set private property to value
            % property must be a string
            this.(property)=value;
        end
        
        function value=get(this, property)
            %get(this, property, value)
            % Get private property value
            value=this.(property);
        end
        
        function set_indep_test(this, test_func)
            %set_indep_test(this, test_func)
            % test_func is a function handle to a statistical independence
            % test with arguments A and B and returning the test statistic
            % and the pvalue.
            if ischar(test_func)
                test_func=str2func(test_func);
            end
            this.indep_test=test_func;
        end
        
        function set_causa_test(this, test_func)
            %set_causa_test(this, test_func)
            % test_func is a function handle to a causal direction test
            % test with arguments A and B and returning the test statistic
            % and the pvalue.
            if ischar(test_func)
                test_func=str2func(test_func);
            end
            this.causa_test=test_func;
        end
        
        function benchmark(this)
            %benchmark(this)
            % Run the causa test for various sizes if inputs
            % and plot time as a function of number of values
            idx_orig=this.subidx;
            d=length(this.A);
            n=2.^[3:floor(log2(d))];
            m=length(n);
            ti=zeros(1,m);
            tc=zeros(1,m);
            for i=1:m
                fprintf(2, 'Number of points: %d; ', n(i));
                this.subidx=1:n(i);
                tic
                indep(this);
                ti(i)=toc;
                tic
                causa(this);
                tc(i)=toc;
                fprintf(2, 'Duration: ti=%5.4f tc=%5.4f\n', ti(i), tc(i));
            end
            % Eliminate first point
            n=n(2:end);
            ti=ti(2:end);
            tc=tc(2:end);
            
            % Indep test
            h=figure; set(h, 'Position', [440 100 562 698]);
            subplot(2,1,1);
            plot(n, ti); hold on, plot(n, ti, '.'); 
            [N, T, formula]=fit(n, ti);
            x=n(end-3); y=2*max(ti)/3;
            text(x, y, formula, 'Fontsize', 14, 'FontWeight', 'bold');
            plot(N,T, 'g');           
            xlabel('N -- Number of points', 'Fontsize', 14);
            leg=sprintf('T -- Duration of %s (sec)', upper(func2str(this.indep_test)));
            ylabel(leg, 'Fontsize', 14);
            
            subplot(2,1,2);
            plot(n, tc); hold on, plot(n, tc, '.'); 
            [N, T, formula]=fit(n, tc);
            x=n(end-3); y=2*max(tc)/3;
            text(x, y, formula, 'Fontsize', 14, 'FontWeight', 'bold');
            plot(N,T, 'g');
            xlabel('N -- Number of points', 'Fontsize', 14);
            leg=sprintf('T -- Duration of %s (sec)', upper(func2str(this.causa_test)));
            ylabel(leg, 'Fontsize', 14);
            this.subidx=idx_orig;
        end
            
        function s=turn2str(this)
            %s=turn2str(this)
            % Displays the pair as a string.
            % A and B are comma separated.
            sA=sprintf(' %g', this.get_A);
            sB=sprintf(' %g', this.get_B);
            s=[sA ',' sB];
        end
            
    end %methods
end % classdef

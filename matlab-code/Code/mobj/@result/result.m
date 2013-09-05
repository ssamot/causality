%=============================================================================
% result Data structure             
%=============================================================================  
% D=result(object)
% 
% Creates a result container given a data object or another result object.
% Warning: a result object is a handle. To make a physical copy of R0, use
% R=result(R0); not R=R0; or use R=subset(R0, idx);
%
% Important:
% For consistency with the Spider objects
% http://www.kyb.mpg.de/bs/people/spider/
% X holds the recognition predictions and Y the truth values.
% Note: if X and/or Y have multiple columns, only the first one is taken
% into account.

%==========================================================================
% Author of code: Isabelle Guyon -- isabelle@clopinet.com -- February 2013
%==========================================================================

classdef result < data

    methods
        %%%%%%%%%%%%%%%%%%%
        %%% CONSTRUCTOR %%%
        %%%%%%%%%%%%%%%%%%%
        function this = result(obj, Y, subidx) 
            %this = result(X, Y, subidx) 
            %this = result(X, Y) 
            %this = result(X)
            %this = result(data)
            if nargin<1, obj=[]; end
            if nargin<2, Y=[]; end
            if nargin<3, subidx=[]; end
            this=this@data(obj, Y, subidx);
            if iscell(this.X), this.X=this.Y; end % X must be a matrix
        end    

        function set_X(this, num, val)
            %set_X(this, num, val)
            num=this.subidx(num);
            this.X(num, :)=val;
        end  
        
        function [a, e]=auc(this)
            % [a, e]=auc(this)
            % Area under the ROC curve and error bar
            Yhat=get_X(this);
            Y=get_Y(this);
            [a, e]=auc(Yhat(:,1), Y(:,1));
        end
            
        function [b, e]=ber(this)
            %[b, e]=ber(this)
            % Balanced error rate and error bar
            Yhat=get_X(this); 
            Y=get_Y(this);
            [b, ~, ~, e]=ber(Yhat(:,1), Y(:,1));
        end
            
        function [a, e]=bac(this)
            % [a, e]=bac(this)
            % Balanced accuracy and error bar
            [b, e]=ber(this);
            if isempty(b); return; end
            a=1-b;
        end

        function h=roc(this, h, col)
            %h=roc(Data, h, col)
            % Plot ROC curve
            % h=figure handle
            % col=color
            if nargin<2, h=figure; end
            if nargin<3, col='k'; end
            Yhat=get_X(this);
            Y=get_Y(this);
            roc(Yhat(:,1), Y(:,1), [],[],[],[],h,col);
        end
            
        function [m, e]=mse(D)
            %m =mse(D)
            % Mean square error
            Yhat=get_X(D);
            Y=get_Y(D);
            m=mean((Yhat - Y(:,1)).^2);
            e=[];
        end
            
    end %methods
        
end % classdef

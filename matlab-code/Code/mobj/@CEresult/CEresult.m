%=============================================================================
% CEresult Data structure             
%=============================================================================  
% D=CEresult(object)
% 
% Creates a result container given a data object or another result object.
% Warning: a result object is a handle. To make a physical copy of R0, use
% R=result(R0); not R=R0; or use R=subset(R0, idx);
%
% For consistency with the Spider objects
% http://www.kyb.mpg.de/bs/people/spider/
% X holds the recognition predictions and Y the truth values.
% For Y matrices (target values):
% - The first column is the target values used to compute the ranking_score.
% - The second column is complementary information used to compute 
% other scores (field called YT in CEdata).

%==========================================================================
% Author of code: Isabelle Guyon -- isabelle@clopinet.com -- February 2013
%==========================================================================

classdef CEresult < result

    methods
        %%%%%%%%%%%%%%%%%%%
        %%% CONSTRUCTOR %%%
        %%%%%%%%%%%%%%%%%%%
        function this = CEresult(obj, Y, subidx) 
            %this = CEresult(X, Y, subidx) 
            %this = CEresult(X, Y) 
            %this = CEresult(X)
            %this = CEresult(data)
            if nargin<3, subidx=[]; end
            if nargin<2, Y=[]; end
            if nargin<1, obj=[]; end
            this=this@result(obj, Y, subidx);
        end    
        
        function [a, e]=CEscore(this, direc, remove_null)
            % [a, e]=CEscore(this, direc, remove_null)
            % Area under the ROC curve and error bar
            % symmetrized, the official ranking score.
            % If direc=1, scores only A->B.
            % If direc=-1, scores only A<-B.
            % If direc=0, averges the two scores.
            % If remove_null ==1, remove the examples of the 
            % null class A|B and A-B (in which case direc does not matter).
            if nargin<2, direc=0; end
            if nargin<3, remove_null=0; end
            a=NaN; e=NaN;
            Y=get_Y(this);
            if ~isempty(Y)
                Target=Y(:,1);
                Details=Y(:,2);
                Output=get_X(this);
                if remove_null
                    gidx=find(Target~=0 & Details~=0); % Remove A - B, A | B, and Unknown
                else
                    gidx=find(Details~=0); % Remove Unknown
                end
                Target=Target(gidx);
                Output=Output(gidx);
                if direc==1
                    [a, e]=AcausesB(Output, Target);
                elseif direc==-1
                    [a, e]=BcausesA(Output, Target);
                else
                    [a, e]=CEscore(Output, Target);
                end
            end
        end
        
        function [a, e]=DEPscore(this, depen)
            % [a, e]=DEPscore(this, depen)
            % Area under the ROC curve and error bar
            % for the separation of A | B (independent) --> depen=0
            % or A - B (dependent not causally related) --> depen=1
            if nargin<2, depen=1; end
            if depen, d=4; else d=3; end
            a=NaN; e=NaN;
            Y=get_Y(this);
            if ~isempty(Y)
                Output=abs(get_X(this));
                Target=2*(abs(Y(:,1))-0.5);
                Details=Y(:,2);
                gidx=find(Details~=d & Details~=0); % Remove A - B and Unknown
                [a, e]=auc(Output(gidx), Target(gidx));
                if isempty(a), a=NaN; end
                if isempty(e), e=NaN; end
            end
        end    
            
    end %methods
        
end % classdef

function [a, e]=ranking_score(Output, Target)
    % [a, e]=ranking_score(Output, Target)
    % Area under the ROC curve and error bar symmetrized
    
    % Isabelle Guyon -- isabelle@clopinet.com -- March 2013
    
    a=NaN; e=NaN;
    nT=size(Target, 1);
    nO=size(Output, 1);

    if isempty(Target) || isempty(Output) || nO~=nT, return, end

    T1=Target(:,1); T1(T1==0)=-1;
    T2=Target(:,1); T2(T2==0)=1;

    [a1, e1]=auc(Output, T1);
    [a2, e2]=auc(Output, T2);
    a=(a1+a2)/2;
    e=(e1+e2)/2;

    if isempty(a), a=NaN; end
    if isempty(e), e=NaN; end
    
end
function [a, e]=AcausesB(Output, Target)
% [a, e]=AcausesB(Output, Target)
% Area under the ROC curve and error bar
% for the causal direction A->B vs everything else
a=NaN; e=NaN;

Target(Target==0)=-1;
[a, e]=auc(Output, Target);

if isempty(a), a=NaN; end
if isempty(e), e=NaN; end

end
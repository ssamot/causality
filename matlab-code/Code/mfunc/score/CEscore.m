function [a, e]=CEscore(Output, Target)
% [a, e]=CEscore(Output, Target)
% Average of two Area under the ROC curves and error bar
% for the causal direction A<-B vs everything else
% and A->B vs everything else

[a1, e1]=AcausesB(Output, Target);
[a2, e2]=BcausesA(Output, Target);

a=(a1+a2)/2;
e=(e1+e2)/2;

end
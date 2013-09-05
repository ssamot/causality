function [errate, errate_pos, errate_neg, Sigma]=ber(Output, Target)
%[errate, errate_pos, errate_neg, sigma]=balanced_errate(Output, Target)
% Compute a "balanced" error rate as the average
% of the error rate of positive examples and the
% error rate of negative examples.
% Inputs:
% Output    --  Classifier outputs in columns of dim (num pattern, num tries)
% Target    -- +-1 target values of dim size(Output,1).
% Returns:
% errate    -- Balanced error rates of all the tries.
% errate_pos -- Error rate of the positive class.
% errate_neg -- Error rate of the negative class.
% Sigma -- Error bar.

% Isabelle Guyon -- March 2006 -- isabelle@clopinet.com
% Modified by Amir Reza Saffari Azar, amir@ymer.org

warning off

errate=[];
errate_pos=[];
errate_neg=[];
Sigma=[];
if size(Output,1)~=size(Target,1), return; end

Output=full(Output);
Output(find(isnan(Output)))=0;
Target=full(Target);

pos_idx=find(Target>0);
neg_idx=find(Target<=0);
n1=length(find(Target==1));
n2=length(find(Target==-1));

for i=1:size(Output,2)
    errate_pos(i)=mean(Output(pos_idx,i)<=0);
    errate_neg(i)=mean(Output(neg_idx,i)>0);
    errate(i)=mean([errate_pos(i),errate_neg(i)]);
    Sigma(i)=(1/2)*sqrt( errate_pos(i)*(1-errate_pos(i))/n1 + errate_neg(i)*(1-errate_neg(i))/n2 );
end

warning on
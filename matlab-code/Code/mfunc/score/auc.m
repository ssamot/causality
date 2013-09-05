function [area, sigma] = auc(Output, Target, pos_small, precise_ebar, show_fig)
%[area, sigma] = auc(Output, Target, pos_small, precise_ebar, show_fig)
% This is the algorithm proposed for 
% computing the AUC and the error bar.
% It is assumed that the outputs provide a score
% with the negative examples having the lowest score
% unless the flag pos_small = 1.
% precise_ebar=1: slower but better error bar calculation.

% Isabelle Guyon -- isabelle@clopinet.com -- December 2007

if nargin<3 | isempty(pos_small), pos_small=0; end
if nargin<4 | isempty(precise_ebar), precise_ebar=0; end
if nargin<5, show_fig=0; end
dosigma=1;
if nargout<2, dosigma=1; end

area=[];
sigma=[];

n=length(Target);
negidx=find(Target<0); % indices of negative class elements
posidx=find(Target>0); % indices of positive class elements
neg=length(negidx);    % number of negative class elements
pos=length(posidx);    % number of positive class elements

if neg==0 | pos==0, return, end

uval=unique(Output);
if ~show_fig & length(uval)==2 & min(uval)==-1 & max(uval)==1
    [area, sigma] = bac(Output, Target);
    return
end

% This is hard to vectorize, we just loop if multiple columns for outputs
[nn,pp]=size(Output);
p=1;
if nn~=1 & pp~=1
    p=pp;
elseif nn==1
    Output=Output';
    Target=Target';
end

for kk=1:p
    
    output=Output(:,kk);
    
    if ~pos_small, output=-output; end
    [u,i]=sort(output); % sort outputs, best come first (u=sorted vals, i=index)

    uval=unique(output);
    
    % Test whether there are ties 
    if length(uval)==n
        S(i)=1:n;   % compute the ranks of the outputs (no ties)
    else
        % Another speed-up trick (maybe not critical): test whether we have a whole bunch
        % of negative examples with the same output
        last_neg=find(output==max(output));
        other=setdiff(1:n, last_neg);
        L=length(last_neg);
        if L>1 & length(unique(output(other)))==length(other)
            S(i)=1:n;
            S(last_neg)=n-(L-1)/2;
        else
        % Average the ranks for the ties 
            oldval=u(1);
            newval=u(1);
            R=1:n;
            k0=1;
            for k=2:n
                newval=u(k);
                if newval==oldval
                    % moving average
                    R(k0:k)=R(k-1)*(k-k0)/(k-k0+1)+R(k)/(k-k0+1);
                else
                    k0=k;
                end
                oldval=newval;
            end
            S(i)=R;
        end

    end

    SS=sort(S(negidx));
    RR=[1:neg];

    SEN=(SS-RR)/pos;                   
    area(kk)=sum(SEN)/neg;                 % compute the AUC

    %%%%%%%%%%%%%%%%%%%%% ERROR BARS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if dosigma
        % Adjust RR for the ties (new Dec 5 correction)
        oldval=SS(1);
        newval=SS(1);
        k0=1;
        j=1;
        for k=2:length(SS)
            newval=SS(k);
            if newval==oldval
                % number of tied values
                nt=k-k0+1;
                % moving average
                RR(k0:k) = RR(k-1)*(k-k0)/nt + RR(k)/nt;
            else
                k0=k;
                j=j+1;
            end
            oldval=newval;
        end

        SEN=(SS-RR)/pos;                   % compute approximate sensitivity
        SPE=1-((1:neg)-0.5)/neg;           % compute approximate specificity
                                           % (new 0.5 Dec 5 correction)

        if precise_ebar                                  
            % Calculate the "true" ROC (slow)
            uval=sort(uval);
            sensitivity=zeros(length(uval)+1, 1);
            specificity=zeros(length(uval)+1, 1);
            sensitivity(1)=0;
            specificity(1)=neg;
            for k=1:length(uval)
                sensitivity(k+1)=sensitivity(k)+length(find(output(posidx)==uval(k)));
                specificity(k+1)=specificity(k)-length(find(output(negidx)==uval(k)));
            end
            sensitivity=sensitivity/pos;
            specificity=specificity/neg;
        else
            sensitivity=SEN;
            specificity=SPE;
        end

        two_BAC=sensitivity+specificity;    % compute twice the balanced accuracy
        [u,k]=max(two_BAC);                 % find its max value
        sen=sensitivity(k);                 % and the corresponding sensitivity
        spe=specificity(k);                 % and specificity
        sigma(kk)= 0.5 * sqrt(sen*(1-sen)/ pos + spe*(1-spe)/ neg); % error bar estimate

        % Plot the results
        if show_fig
            figure; bar(SPE, SEN); xlim([0,1]); ylim([0,1]); grid on
            xlabel('Specificity'); ylabel('Sensitivity');
            hold on; plot(specificity, sensitivity, 'ro'); plot(specificity, sensitivity, 'r-', 'LineWidth', 2); 
            title(['AUC=' num2str(area) '+-' num2str(sigma)]);
        end
    
    end % if dosigma

    end % for kk

return



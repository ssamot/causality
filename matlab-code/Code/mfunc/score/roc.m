function [h, spefound, senfound, espefound, esenfound] = roc(Output, Target, senval, speval, sim_name, silent, h, col)
%function [h, spefound, senfound, espefound, esenfound] = roc(Output, Target, senval, speval, sim_name, silent, h, col)
% Compute ROC curves from two vectors:
% Output --   matrix of classifier real output values
% Target --   +- corresponding target values
% Returns:
% h     -- Figure handle.
% Isabelle Guyon -- March-June 2003 -- isabelle@clopinet.com

if nargin<3, senval=[]; end
if nargin<4, speval=[]; end
if (nargin<5|isempty(sim_name)), sim_name=''; end
if (nargin<6|isempty(silent)), silent=0; end
if nargin<7 | h==0, h=[]; end
if nargin<8, col='k'; end

Posidx = find(Target>0);
Negidx = find(Target<0);
Posout = Output(Posidx);
Negout = Output(Negidx);
Sposout = sort(Posout);
Snegout = sort(Negout);

ln=length(Negout);
lp=length(Posout);


% Create big vectors with sensitivity and specificity for all threshold
% values
% A small value
allout=[Snegout; Sposout];
epsilon = abs(max(allout)-min(allout))/10000;
%Thetaneg=sort([Snegout(1)-2*epsilon, Snegout', Snegout', Snegout(length(Snegout))+2*epsilon]);
%Thetapos=sort([Sposout(1)-2*epsilon, Sposout', Sposout', Sposout(length(Sposout))+2*epsilon]);
Thetaneg=sort([Snegout(1)-2*epsilon, Snegout', Snegout(length(Snegout))+2*epsilon]);
Thetapos=sort([Sposout(1)-2*epsilon, Sposout', Sposout(length(Sposout))+2*epsilon]);


epsival=10^-6;
%Sensitivity=-sort(-[1, 1:-1/lp:1/lp, 1-1/lp:-1/lp:1/lp, 0, 0]);
%Specificity=sort([0, 0, 1/ln:1/ln:1-1/ln, 1/ln:1/ln:1, 1]);
Sensitivity=[1, 1:-1/lp:1/lp, 0];
Specificity=[0, 1/ln:1/ln:1, 1];

% Eliminate identical theta values:
idx_elim=[];
i=1;
while i<length(Thetapos)
    tval=Thetapos(i);
    if(Thetapos(i+1)==tval)
        Thetapos(i)=tval-epsilon;
        if i+1==length(Thetapos)
            Thetapos(i+1)=tval+epsilon;
        end
        for j=i+1:length(Thetapos)-1
            if(Thetapos(j+1)==tval)
                idx_elim=[idx_elim j];
            else
                Thetapos(j)=tval+epsilon;
                break
            end
        end
        i=j+1;
    else
        i=i+1;
    end
end
valid_idx=setdiff([1:length(Thetapos)], idx_elim);
Thetapos=Thetapos(valid_idx);
VSensitivity=Sensitivity(valid_idx);

idx_elim=[];
i=1;
while i<length(Thetaneg)
    tval=Thetaneg(i);
    if(Thetaneg(i+1)==tval)
        Thetaneg(i)=tval-epsilon;
        if i+1==length(Thetaneg)
            Thetaneg(i+1)=tval+epsilon;
        end
        for j=i+1:length(Thetaneg)-1
            if(Thetaneg(j+1)==tval)
                idx_elim=[idx_elim j];
            else
                Thetaneg(j)=tval+epsilon;
                break
            end
        end
        i=j+1;
    else
        i=i+1;
    end
end
valid_idx=setdiff([1:length(Thetaneg)], idx_elim);
Thetaneg=Thetaneg(valid_idx);
VSpecificity=Specificity(valid_idx);

% Note: to do it absolutely clean, we should have the same value before and
% after the staircase jump.

Theta=[Thetaneg, Thetapos];
NSensitivity=[zeros(1,length(Thetaneg)), VSensitivity];
NSpecificity=[VSpecificity, zeros(1,length(Thetapos))];

% Sort in the order of the threshold on the output
% The Specificity increases with Theta, the Sensitivity decreases
[Stheta, idx]=sort(Theta);
Ssensitivity=NSensitivity(idx);
Sspecificity=NSpecificity(idx);

num_val=length(Ssensitivity);
% Fill in missing values of sensitivity
if Ssensitivity(1)==0, Ssensitivity(1)=1; end
if Ssensitivity(num_val)==0, Ssensitivity(num_val)=epsival; end
for i=2:num_val
    if Ssensitivity(i)==0
        thetamin=Stheta(i-1);
        smin=Ssensitivity(i-1);
        thetamax=[];
        for j=i+1:num_val
            if Ssensitivity(j)~=0
                thetamax=Stheta(j);
                smax=Ssensitivity(j);
                break
            end
        end
        if (isempty(thetamax) | thetamax==thetamin)
            disp 'gasp_sen'
            Ssensitivity(i)=Ssensitivity(i-1);
        else
            % linearly interpolate
            Ssensitivity(i)= smin+(Stheta(i)-thetamin)*(smax-smin)/(thetamax-thetamin);
        end
    end
end

% Fill in missing values of specificity
if Sspecificity(1)==0, Sspecificity(1)=epsival; end
if Sspecificity(num_val)==0, Sspecificity(num_val)=1; end
for i=2:num_val
    if Sspecificity(i)==0
        thetamin=Stheta(i-1);
        smin=Sspecificity(i-1);
        thetamax=[];
        for j=i+1:length(Sspecificity)
            if Sspecificity(j)~=0
                thetamax=Stheta(j);
                smax=Sspecificity(j);
                break
            end
        end
        if isempty(thetamax) | thetamax==thetamin
            disp 'gasp_spe'
            Sspecificity(i)=Sspecificity(i-1);
        else
            % linearly interpolate
            Sspecificity(i)= smin+(Stheta(i)-thetamin)*(smax-smin)/(thetamax-thetamin);
        end
    end
end

% Probe the curve for the 2 values asked
if (~isempty(senval))
    if senval<=Ssensitivity(num_val)
        spefound=Sspecificity(num_val);
    else
        for i=num_val-1:-1:1
            if senval<Ssensitivity(i)
                senmax=Ssensitivity(i);
                spemax=Sspecificity(i);
                break
            end
        end
        if i>1
            senmin=Ssensitivity(i+1);
            spemin=Sspecificity(i+1);
            spefound=spemin+(senval-senmin)*(spemax-spemin)/(senmax-senmin);
        else
            spefound=Sspecificity(i);
        end
    end
end
if ~isempty(speval)
        if speval<=Sspecificity(1)
        senfound=Ssensitivity(1);
    else
        for i=2:num_val
            if speval<Sspecificity(i)
                spemax=Sspecificity(i);
                senmax=Ssensitivity(i);
                break
            end
        end
        if i<num_val
            spemin=Sspecificity(i-1);
            senmin=Ssensitivity(i-1);
            senfound=senmin+(speval-spemin)*(senmax-senmin)/(spemax-spemin);
        else
            senfound=Ssensitivity(i);
        end 
    end
end

% Compute the area under the curve:
if 1==2
deltas=Sspecificity(2:length(Sspecificity))-Sspecificity(1:length(Sspecificity)-1);
midvals=(Ssensitivity(2:length(Ssensitivity))+Ssensitivity(1:length(Ssensitivity)-1))/2;
norma=abs(sum(deltas));
AUC1=abs(sum(deltas.*midvals))/norma;

deltas=Ssensitivity(2:length(Ssensitivity))-Ssensitivity(1:length(Ssensitivity)-1);
midvals=(Sspecificity(2:length(Sspecificity))+Sspecificity(1:length(Sspecificity)-1))/2;
norma=abs(sum(deltas));
AUC2=abs(sum(deltas.*midvals))/norma;

AUC=max(AUC1,AUC2);
end
AUC=auc(Output, Target);

% Make the plot:
overlay=0;
if ~silent
    if isempty(h)
        h=figure('Name', [sim_name ' ROC curves']);
    end
    hold on
    if col=='k'
        lw=3;
    else
        lw=2;
        overlay=1;
    end
    plot(Sspecificity, Ssensitivity, col, 'LineWidth',lw);
    set(gca, 'XTick', [0:.1:1]);
    set(gca, 'YTick', [0:.1:1]);
    hold on
    plot([0 1], [1 0], 'k');
    if ~overlay
        if (~isempty(senval) & ~isempty(speval))
            title(['AUC=' num2str(round(10000*AUC)/10000) ' -- (sensitivity, specificity): (', num2str(senval), ', ' num2str(round(100*spefound)/100), '), (' , num2str(round(100*senfound)/100) ', ', num2str(speval), ')'], 'FontSize', 14);
        else
            title(['AUC=' num2str(round(10000*AUC)/10000)], 'FontSize', 14);
        end
        xlabel('Specificity', 'FontSize', 14);
        ylabel('Sensitivity', 'FontSize', 14);
        grid on
    end
    if ~isempty(senval)
        hold on
        plot(spefound, senval, 'ro');
    end
    if ~isempty(speval)
        hold on
        plot(speval, senfound, 'ro');
    end
    if (~isempty(senval) & ~isempty(speval))
        hold on
        plot(speval, senval, 'r+');
    end
    
end

if (~isempty(senval) & ~isempty(speval))
    esenfound=sqrt(senfound*(1-senfound)/length(Posidx));
    espefound=sqrt(spefound*(1-spefound)/length(Negidx));
end

% Save the file
if ~isempty(sim_name)
    saveas(h, [sim_name '_ROC_curves.emf'], 'emf');
end

return
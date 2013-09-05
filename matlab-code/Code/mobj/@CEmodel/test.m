function resu = test(this, mydata)
%resu = test(this, mydata)
% Make predictions with a CEmodel.
% Inputs:
% this -- A CEmodel object.
% mydata -- A CEdata object.
% Returns:
% resu -- A CEresult data structure. WARNING: this follows the convention of
% Spider http://www.kyb.mpg.de/bs/people/spider/ *** The result is in resu.X!!!! ***
% resu.Y are the target values.

% Isabelle Guyon -- February 2013 -- isabelle@clopinet.com

if this.verbosity>0, fprintf('\n==TE> Testing %s... \n', class(this)); end

% Limit the number of test examples and randomly permute them
P0=length(mydata);
P=min(P0, this.max_test_num); 
if P<P0, shuffle(mydata, P); end

if this.verbosity<3
    warning off % Some causality test issue warnings that we ignore...
end

% Loop over the samples 
V=zeros(P, 1);
YY=get_Y(mydata);              % target values
subidx=get_subidx(mydata);     % indices of examples chosen

if this.verbosity>1
    if ~isempty(YY)
        fprintf('\nSnum\tTarget\t%s', upper(func2str(this.causa_tests{this.chosen_causa})));
    else
        fprintf('\nSnum\t%s', upper(func2str(this.causa_tests{this.chosen_causa})));
    end
end

for k=1:P
    % Monitor progress
    if this.verbosity>1  
        if ~isempty(YY)
            fprintf('\n%d\t%d\t', subidx(k), YY(k));
        else
            fprintf('\n%d\t', subidx(k));
        end
    elseif this.verbosity==1,
        if ~mod(k, round(P/10))
            fprintf(' %d%% ', round(k/P*100));
        end
    end
    % Compute the recognition results
    pair=get_X(mydata, k);
    V(k)=exec(this, pair);
    if this.verbosity>1
        fprintf('%5.2f', V(k)); 
    end
end
warning on

% Save the results
subidx=get_subidx(mydata);
X=NaN*ones(P0,1);
X(subidx)=V;
Y = [mydata.Y, mydata.YT]; 
resu = CEresult(X, Y, subidx);

if this.verbosity>0, fprintf('\n==TE> Done testing %s... ', class(this)); end

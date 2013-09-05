function R = score_resu(resu_file, data_dir, type)
%R = score_resu(resu_file, data_dir, type)
% Score a file for the cause-effect pair challenge
% Inputs:
% resu_file --   predited values
% data_dir --    directory where the data and truth 
% Returns:
% R --           a structure holding the resuts

% Isabelle Guyon -- isabelle@clopinet.com -- February 2013

if isempty(type), type='test'; end

% Load the truth values
[Y, K]=get_truth(data_dir, type);

% Load the results
Yhat=get_resu(resu_file, type);

% Create a result object
RCE=CEresult(Yhat, Y);

% Compute various scores
if K
    R.Rejection=dependency_score(RCE);
else
    R.Dependency=dependency_score(RCE);
    R.Confounding=confounding_score(RCE);
end
R.Causality=causality_score(RCE);
R.Score=ranking_score(RCE);

return

end
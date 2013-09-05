% Do an epoch

testcost        % Test whether cost function has improved; if not, backtrack

wadapt_pnl          % Adapt weights

arrinit         % Initialize arrays

forward_zeromean_pnl         % Propagate forward
% forward

costderiv_MND       % Compute cost function and its derivatives, for backprop

back            % Propagate backwards

% disp('MODIFIED BY ME, with regularization!!!'),
compgrad_MND        % Compute gradient relative to weights

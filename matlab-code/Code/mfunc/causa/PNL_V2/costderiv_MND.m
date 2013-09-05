% Compute cost function and its derivatives for backprop

% First, compute the derivatives and 2nd derivatives of sigmoids

for subnet=1:ninputs
%   deriv2{subnet} = 1 - output2{subnet}(1:nhidden,:) .^ 2;                 % for tanh sigmoids
%   deriv4{subnet} = 1 - output4{subnet}(1:nextra,:) .^ 2;                  % for tanh sigmoids
%   derder2{subnet} = -2 * output2{subnet}(1:nhidden,:) .* deriv2{subnet};  % for tanh sigmoids
%   derder4{subnet} = -2 * output4{subnet}(1:nextra,:) .* deriv4{subnet};   % for tanh sigmoids
%   
   deriv2{subnet} = 2 ./ (pi .* (1 + input2{subnet} .^2));               % for arctangent sigmoids
   deriv4{subnet} = 2 ./ (pi .* (1 + input4{subnet} .^2));               % for arctangent sigmoids
   derder2{subnet} = - pi * input2{subnet} .* deriv2{subnet} .^ 2;       % for arctangent sigmoids
   derder4{subnet} = - pi * input4{subnet} .* deriv4{subnet} .^ 2;       % for arctangent sigmoids
end


% Now, compute the jacobians

for column=1:ninputs
   for subnet = 1:ninputs
      jacob2i{subnet,column} = repmat(weight12{subnet}(:,column),1,ntrain);
      jacob2o{subnet,column} = deriv2{subnet} .* jacob2i{subnet,column};
      jacob3{subnet,column} = weight23{subnet}(:,1:nhidden) * jacob2o{subnet,column} + repmat(weight13{subnet}(:,column),1,ntrain);
      jacob4i{subnet,column} = weight34{subnet}(:,1) * jacob3{subnet,column};
      jacob4o{subnet,column} = deriv4{subnet} .* jacob4i{subnet,column};
      jacob5{column}(subnet,:) = weight45{subnet}(:,1:nextra) * jacob4o{subnet,column};
   end
end

% Rearrange the output jacobians as a cell array indexed by patterns,
%   and compute determinants and inverse-transposes.
%   This rearrangement is done for efficiency purposes

jacob5p = num2cell(cat(3,jacob5{:}),[1 3]);

for pattern=1:ntrain
   jacob5p{pattern} = squeeze(jacob5p{pattern});
   determ(pattern) = det(jacob5p{pattern});
   jback5p{pattern} = -inv(jacob5p{pattern})';
end

% Compute cost. First, term related to weight decay

cost = 0;

for subnet=1:ninputs
   cost = cost + .5 * (...
      wdecayf12 * sum(sum(weight12{subnet}(:,1:ninputs).^2)) +...
      wdecayf23 * sum(sum(weight23{subnet}(:,1:nhidden).^2)) +...
      wdecayf34 * sum(sum(weight34{subnet}(:,1).^2)));
end

% Then, cost term related to Jacobian. Check whether we're having numerical problems

if min(abs(determ)) < 1e-26 %%% for sparse!!! modified by Zhang Kun: 10-->11
   cost = NaN;
else
   cost = (cost - sum(log(abs(determ)))) / ntrain;
end

% y_1 = [];
% for subnet = 1:ninputs
%     y_1 = [y_1; output3{subnet}(1,:)];
% end
% y_1 = [y_1; ones(1,ntrain)];
% cost = cost - sum(diag((output1(1:ninputs,:)*y_1'/ntrain)* diag(1./diag(y_1*y_1'/ntrain)) *( y_1*output1(1:ninputs,:)'/ntrain))) * lambda; 
% % cost_back = [cost_back cost];
% % thisone = sum(diag((output1(1:ninputs,:)*y_1'/ntrain)* diag(1./diag(y_1*y_1'/ntrain)) *( y_1*output1(1:ninputs,:)'/ntrain)));
% Astar = trpattern * y_1'/ntrain * inv(y_1*y_1'/ntrain);
% SE = [SE sum(diag( (trpattern-Astar*y_1)*(trpattern-Astar*y_1)'/ntrain ))/sum(diag(trpattern*trpattern'/ntrain))];

% Put jacobian-backprop data in normal order (cell array indexed by column of 
%   [square] backpropagated array, with number of training pattern as second 
%   index in each cell).
%   Once again, this rearrangement is for efficiency purposes
jback5 = num2cell(cat(3,jback5p{:}),[1 3]);

for column=1:ninputs
   jback5{column} = squeeze(jback5{column});
end

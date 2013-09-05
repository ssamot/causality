
% Perform separation on test signals

% Input:  mixeddata (array, ninputs x <any size>)
% Output: separdata (array, same size as mixeddata)

truentrain = ntrain;
sz = size(mixeddata);
ntrain = sz(2);
separdata = zeros(sz);

for subnet=1:ninputs
   output2{subnet} = ones(nhidden+1,ntrain);             % these are for the biases
end
output1 = ones(ninputs+1,ntrain);   % biases again

% Propagate forward

output1(1:ninputs,:) = mixeddata;

for subnet=1:ninputs
   %output2{subnet}(1:nhidden,:) = tanh(weight12{subnet} * output1);                 % For tanh sigmoid
   output2{subnet}(1:nhidden,:) = (2/pi) * atan(weight12{subnet} * output1);         % For arctangent sigmoid
   separdata(subnet,:) = weight23{subnet} * output2{subnet} + weight13{subnet} * output1;
end

ntrain = truentrain;

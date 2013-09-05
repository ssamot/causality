% Propagate forward

output1(1:ninputs,:) = trpattern;

for subnet=1:ninputs
    input2{subnet} = weight12{subnet} * output1;
    %output2{subnet}(1:nhidden,:) = tanh(input2{subnet});           % for tanh sigmoids
    output2{subnet}(1:nhidden,:) = (2/pi) * atan(input2{subnet});   % for arctangent sigmoids

    input3{subnet} = weight23{subnet} * output2{subnet} + weight13{subnet} * output1;
    % y
    output3{subnet}(1,:) = input3{subnet};
    fx1 = weight23{1}(1:nhidden/2) * output2{1}(1:nhidden/2,:)  + weight13{1}(1) * trpattern(1,:);
    fx2 = weight23{1}(1+nhidden/2:nhidden) * output2{1}(1+nhidden/2:nhidden,:)  + weight13{1}(2) * trpattern(2,:);

    %%%% to make y (output3) zero-mean
    if ~mod(epoch,20) % such that b(2) will not be too large??
        weight23{subnet}(nhidden+1) = weight23{subnet}(nhidden+1) - mean(output3{subnet}(1,:));
        %% weights in next layer also need adjusting
        weight34{subnet}(:,2) = weight34{subnet}(:,1) * mean(output3{subnet}(1,:)) + weight34{subnet}(:,2);
        output3{subnet}(1,:) = output3{subnet}(1,:) - mean(output3{subnet}(1,:));
    end
    %%%%

    input4{subnet} = weight34{subnet} * output3{subnet};
    %output4{subnet}(1:nextra,:) = tanh(input4{subnet});            % for tanh sigmoids
    output4{subnet}(1:nextra,:) = (2/pi) * atan(input4{subnet});    % for arctangent sigmoids

    output{subnet} = weight45{subnet} * output4{subnet};
end

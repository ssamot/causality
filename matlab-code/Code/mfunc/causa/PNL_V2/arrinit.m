% Initialize arrays for forward and backward propagations

for subnet=1:ninputs
   back2{subnet} = zeros(nhidden,ntrain);
   back3{subnet} = zeros(1,ntrain);
   back4{subnet} = zeros(nextra,ntrain);
   
   grad12{subnet} = zeros(nhidden,ninputs+1);
   grad23{subnet} = zeros(1,nhidden+1);
   grad13{subnet} = zeros(1,ninputs+1);
   grad34{subnet} = zeros(nextra,2);
   grad45{subnet} = zeros(1,nextra+1);
   
   output2{subnet} = ones(nhidden+1,ntrain);             % these are for the biases
   output3{subnet} = ones(2,ntrain);                     % these too
   output4{subnet} = zeros(nextra+1,ntrain);             % no biases here (linear outputs)
end
output1 = ones(ninputs+1,ntrain);                        % biases again

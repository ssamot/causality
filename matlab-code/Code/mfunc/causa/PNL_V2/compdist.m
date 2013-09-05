% Compute estimated cumulative distributions

% Compute uniform grid for each component

for subnet=1:ninputs
   minimum = min(input3{subnet});
   maximum = max(input3{subnet});
   cgrid{subnet} = minimum:(maximum-minimum)/(ndistr-1):maximum;
end

% Propagate forward in distribution estimation layers

for subnet=1:ninputs
   output3_p{subnet} = cgrid{subnet};
   output3_p{subnet}(2,:) = 1;
   input4_p{subnet} = weight34{subnet} * output3_p{subnet};
%   output4{subnet} = tanh(input4{subnet});
   output4_p{subnet} = (2/pi) * atan(input4_p{subnet});
   output4_p{subnet}(nextra+1,:) = 0;
   output_p{subnet} = weight45{subnet} * output4_p{subnet};
end

% netinit_during
eta0 = 1e-6;
eta013 = eta0;    % eta0 for weights between layers 1,2 and 3
up =  1.2;
down = 1/up;
tolerance = 1e-8;  % tolerance is additive because cost is logarithmic
reduce = down;
alpha = .99;

for subnet = 1:ninputs
    eta12{subnet} = ones(size(weight12{subnet})) * eta013;
    eta23{subnet} = ones(size(weight23{subnet})) * eta013;
    eta13{subnet} = ones(size(weight13{subnet})) * eta013;
    eta34{subnet} = ones(size(weight34{subnet})) * eta0;
    eta45{subnet} = ones(size(weight45{subnet})) * eta0;
end
% create and initialize network variables
% if IF_direct
%     figure(8), [icasig, AA, W] = fastica(trpattern, 'approach', 'symm', 'g', 'tanh');
% end

% Especially for the PNL causal analysis with two variables
    weight12{1} = (rand(nhidden,ninputs+1) - .5) * (2 * weightrange)/6; % % /6: Now...
    % Two zero sub-blocks of weight12{1}
    weight12{1}(1:nhidden/2, 2) = 0;
    weight12{1}(nhidden/2+1:nhidden, 1) = 0;
    
    weight12{2} = zeros(nhidden,ninputs+1);
    
%     weight23{subnet} = (rand(1,nhidden+1) - .5) * (2 * weightrange);
    if(IF_direct)
%         if Linear_init
%             weight12{subnet} = (rand(nhidden,ninputs+1) - .5) * (2 * weightrange) *0.4;
%             weight13{subnet} = [W(subnet,:) 0];
%             weight23{subnet} = (rand(1,nhidden+1) - .5) * (2 * weightrange) * 0.4;
%         else
%             weight13{subnet} = (rand(1,ninputs+1) - .5) * (2 * weightrange);
%             weight23{subnet} = (rand(1,nhidden+1) - .5) * (2 * weightrange);
%         end
%     else
        weight13{1} = (rand(1,ninputs+1) - .5) * 0;
        weight13{1}(1) = 1; % these weighs are fixed and will not be updated...
        weight13{1}(2) = -trpattern(1,:)*trpattern(2,:)'/(trpattern(2,:)*trpattern(2,:)');
        weight13{2} = zeros(1,ninputs+1); % 1-by-3: 0, 1, and bias...
        weight13{2}(2) = 1; 
        weight23{1} = (rand(1,nhidden+1) - .5) * (2 * weightrange);
        weight23{2} = zeros(1,nhidden+1);
    end
for subnet=1:ninputs
    weight34{subnet} = rand(nextra,2) * weightrange;                 % 34 and 45 have to be positive
    weight45{subnet} = rand(1,nextra+1) * weightrange;

    grad12{subnet} = zeros(size(weight12{subnet}));         % not really necessary, except
    grad23{subnet} = zeros(size(weight23{subnet}));         % for the test of grad45{1}
    grad13{subnet} = zeros(size(weight13{subnet}));         % in 'testcost'
    grad34{subnet} = zeros(size(weight34{subnet}));
    grad45{subnet} = zeros(size(weight45{subnet}));
    
    grad12old{subnet} = zeros(size(weight12{subnet}));
    grad23old{subnet} = zeros(size(weight23{subnet}));
    grad13old{subnet} = zeros(size(weight13{subnet}));
    grad34old{subnet} = zeros(size(weight34{subnet}));
    grad45old{subnet} = zeros(size(weight45{subnet}));
    
    z12{subnet} = zeros(size(weight12{subnet}));
    z23{subnet} = zeros(size(weight23{subnet}));
    z13{subnet} = zeros(size(weight13{subnet}));
    z34{subnet} = zeros(size(weight34{subnet}));
    z45{subnet} = zeros(size(weight45{subnet}));
    
    eta12{subnet} = ones(size(weight12{subnet})) * eta013;
    eta23{subnet} = ones(size(weight23{subnet})) * eta013;
    eta13{subnet} = ones(size(weight13{subnet})) * eta013;
    eta34{subnet} = ones(size(weight34{subnet})) * eta0;
    eta45{subnet} = ones(size(weight45{subnet})) * eta0;
end

mincost = 1E20;
cost = mincost;
epochs = 0;
falseepochs = 0;



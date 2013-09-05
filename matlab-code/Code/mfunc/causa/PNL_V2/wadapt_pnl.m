% Adapt weights

for subnet=1:ninputs
    
    if epochs > initialepochs
        z12{subnet} = grad12{subnet} + alpha * z12{subnet};
        z23{subnet} = grad23{subnet} + alpha * z23{subnet};
        z13{subnet} = grad13{subnet} + alpha * z13{subnet};
        
        eta12up{subnet} = (grad12{subnet} .* grad12old{subnet}) >= 0;
        eta23up{subnet} = (grad23{subnet} .* grad23old{subnet}) >= 0;
        eta13up{subnet} = (grad13{subnet} .* grad13old{subnet}) >= 0;
        
        eta12{subnet} = eta12{subnet} .* (up * eta12up{subnet} + down * (1 - eta12up{subnet}));
        eta23{subnet} = eta23{subnet} .* (up * eta23up{subnet} + down * (1 - eta23up{subnet}));
        eta13{subnet} = eta13{subnet} .* (up * eta13up{subnet} + down * (1 - eta13up{subnet}));
        
        if subnet == 1
            weight12{subnet} = weight12{subnet} - eta12{subnet} .* z12{subnet};
            % Especially for PNL causal analysis with two variables
            weight12{1}(1:nhidden/2, 2) = 0;
            weight12{1}(nhidden/2+1:nhidden, 1) = 0;
            
            weight12{2} = zeros(nhidden,ninputs+1);
            
            weight23{subnet} = weight23{subnet} - eta23{subnet} .* z23{subnet};
            weight23{2} = zeros(1,nhidden+1);
        end
        %% CAUTION!~~~
        % If_direct,
        % Now IF_direct is fixed...
        if (IF_direct)
            if subnet == 1
                weight13{subnet} = weight13{subnet} - eta13{subnet} .* z13{subnet};
            end
        end
        
        grad12old{subnet} = grad12{subnet};
        grad23old{subnet} = grad23{subnet};
        grad13old{subnet} = grad13{subnet};
    elseif Init_f == 1% just update f for initialization
        if subnet == 1
            % z and eta
            z12{subnet}(nhidden/2+1:nhidden, :) = grad12{subnet}(nhidden/2+1:nhidden, :) + alpha * z12{subnet}(nhidden/2+1:nhidden, :);
            z23{subnet}(1,nhidden/2+1:nhidden) = grad23{subnet}(1,nhidden/2+1:nhidden) + alpha * z23{subnet}(1,nhidden/2+1:nhidden);
            z13{subnet}(2:end) = grad13{subnet}(2:end) + alpha * z13{subnet}(2:end);
            
            Tmp12 = (grad12{subnet}(nhidden/2+1:nhidden, :) .* grad12old{subnet}(nhidden/2+1:nhidden, :)) >= 0;
            Tmp23 = (grad23{subnet}(1,nhidden/2+1:nhidden) .* grad23old{subnet}(1,nhidden/2+1:nhidden)) >= 0;
            Tmp13 = (grad13{subnet}(2:end) .* grad13old{subnet}(2:end)) >= 0;
            
            eta12{subnet}(nhidden/2+1:nhidden, :) = eta12{subnet}(nhidden/2+1:nhidden, :) .* (up * Tmp12 + down * (1 - Tmp12));
            eta23{subnet}(1,nhidden/2+1:nhidden) = eta23{subnet}(1,nhidden/2+1:nhidden) .* (up * Tmp23 + down * (1 - Tmp23));
            eta13{subnet}(2:end) = eta13{subnet}(2:end) .* (up * Tmp13 + down * (1 - Tmp13));
            
            % update
            weight12{subnet}(nhidden/2+1:nhidden, :) = weight12{subnet}(nhidden/2+1:nhidden, :) - eta12{subnet}(nhidden/2+1:nhidden, :) .* z12{subnet}(nhidden/2+1:nhidden, :);
            % Especially for PNL causal analysis with two variables
            %           weight12{1}(1:nhidden/2, 2) = 0;
            weight12{1}(nhidden/2+1:nhidden, 1) = 0;
            
            %           weight12{2} = zeros(nhidden,ninputs+1);
            
            weight23{subnet}(1,nhidden/2+1:nhidden) = weight23{subnet}(1,nhidden/2+1:nhidden) - eta23{subnet}(1,nhidden/2+1:nhidden) .* z23{subnet}(1,nhidden/2+1:nhidden);
            %           weight23{2} = zeros(1,nhidden+1);
            weight13{subnet}(2:end) = weight13{subnet}(2:end) - eta13{subnet}(2:end) .* z13{subnet}(2:end);
            grad12old{subnet} = grad12{subnet};
            grad23old{subnet} = grad23{subnet};
            grad13old{subnet} = grad13{subnet};
        end
    end
    
    z34{subnet} = grad34{subnet} + alpha * z34{subnet};
    z45{subnet} = grad45{subnet} + alpha * z45{subnet};
    
    eta34up{subnet} = (grad34{subnet} .* grad34old{subnet}) >= 0;
    eta45up{subnet} = (grad45{subnet} .* grad45old{subnet}) >= 0;
    
    eta34{subnet} = eta34{subnet} .* (up * eta34up{subnet} + down * (1 - eta34up{subnet}));
    eta45{subnet} = eta45{subnet} .* (up * eta45up{subnet} + down * (1 - eta45up{subnet}));
    
    weight34{subnet} = weight34{subnet} - eta34{subnet} .* z34{subnet};
    weight45{subnet} = weight45{subnet} - eta45{subnet} .* z45{subnet};
    
    grad34old{subnet} = grad34{subnet};
    grad45old{subnet} = grad45{subnet};
end

% Normalize output weight vectors to norm 1/sqrt(nextra)

for subnet=1:ninputs
    weight45{subnet}(1,1:nextra) = weight45{subnet}(1,1:nextra) / (norm(weight45{subnet}(1,1:nextra)) * sqrt(nextra));
end

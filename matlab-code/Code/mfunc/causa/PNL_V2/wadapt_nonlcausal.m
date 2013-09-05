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
      
      weight12{subnet} = weight12{subnet} - eta12{subnet} .* z12{subnet};
%       % Now we set this one to zero...
      weight12{subnet}(:,subnet) = 0;
      weight23{subnet} = weight23{subnet} - eta23{subnet} .* z23{subnet};
      %% CAUTION!~~~
      % If_direct,
%       % Now IF_direct is fixed...
%       if (IF_direct)
%           weight13{subnet} = weight13{subnet} - eta13{subnet} .* z13{subnet};
%       end
      
      grad12old{subnet} = grad12{subnet};
      grad23old{subnet} = grad23{subnet};
      grad13old{subnet} = grad13{subnet};
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

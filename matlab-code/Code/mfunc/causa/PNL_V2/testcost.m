% Test if cost has improved, and if not backtrack, reduce etas and set momentum memory
% to zero

if (cost - mincost) > tolerance | isnan(cost) |sum(sum(isnan(grad45{1})))  % tolerance is additive because cost is logarithmic
   for subnet=1:ninputs
      
      % Backtrack to point of minimum cost
      
      weight12{subnet} = minweight12{subnet};
      weight23{subnet} = minweight23{subnet};
      weight13{subnet} = minweight13{subnet};
      weight34{subnet} = minweight34{subnet};
      weight45{subnet} = minweight45{subnet};
          
      grad12{subnet} = mingrad12{subnet};
      grad23{subnet} = mingrad23{subnet};
      grad13{subnet} = mingrad13{subnet};
      grad34{subnet} = mingrad34{subnet};
      grad45{subnet} = mingrad45{subnet};
      
      % Set momentum memory to zero
      
      z12{subnet} = zeros(size(z12{subnet}));
      z23{subnet} = zeros(size(z23{subnet}));
      z13{subnet} = zeros(size(z13{subnet}));
      z34{subnet} = zeros(size(z34{subnet}));
      z45{subnet} = zeros(size(z45{subnet}));
      
      % Reduce step sizes computed at point of minimum cost
      
      mineta12{subnet} = mineta12{subnet} * reduce;
      mineta23{subnet} = mineta23{subnet} * reduce;
      mineta13{subnet} = mineta13{subnet} * reduce;
      mineta34{subnet} = mineta34{subnet} * reduce;
      mineta45{subnet} = mineta45{subnet} * reduce;
      
      eta12{subnet} = mineta12{subnet};
      eta23{subnet} = mineta23{subnet};
      eta13{subnet} = mineta13{subnet};
      eta34{subnet} = mineta34{subnet};
      eta45{subnet} = mineta45{subnet};
   end
   
   falseepochs = falseepochs + 1;
   
else
   
   if cost < mincost
      
      % Note new minimum cost position and corresponding cost, gradient and step sizes
      
      mincost = cost;
      
      for subnet=1:ninputs
         minweight12{subnet} = weight12{subnet};
         minweight23{subnet} = weight23{subnet};
         minweight13{subnet} = weight13{subnet};
         minweight34{subnet} = weight34{subnet};
         minweight45{subnet} = weight45{subnet};
         
         mingrad12{subnet} = grad12{subnet};
         mingrad23{subnet} = grad23{subnet};
         mingrad13{subnet} = grad13{subnet};
         mingrad34{subnet} = grad34{subnet};
         mingrad45{subnet} = grad45{subnet};
         
         mineta12{subnet} = eta12{subnet};
         mineta23{subnet} = eta23{subnet};
         mineta13{subnet} = eta13{subnet};
         mineta34{subnet} = eta34{subnet};
         mineta45{subnet} = eta45{subnet};
      end
   end
end

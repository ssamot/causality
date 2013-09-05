% Propagate backwards

for column=1:ninputs
   for subnet=1:ninputs
      jback4o{subnet,column} = weight45{subnet}(:,1:nextra)' * jback5{column}(subnet,:);
      jback4i{subnet,column} = deriv4{subnet} .* jback4o{subnet,column};
      back4{subnet} = back4{subnet} + derder4{subnet} .* jacob4i{subnet,column} .* jback4o{subnet,column};
      jback3{subnet,column} = weight34{subnet}(:,1)' * jback4i{subnet,column};
      jback2o{subnet,column} = weight23{subnet}(:,1:nhidden)' * jback3{subnet,column};
      jback2i{subnet,column} = deriv2{subnet} .* jback2o{subnet,column};
      back2{subnet} = back2{subnet} + derder2{subnet} .* jacob2i{subnet,column} .* jback2o{subnet,column};
   end
end

for subnet=1:ninputs
   back3{subnet} = weight34{subnet}(:,1)' * back4{subnet};
   back2{subnet} = back2{subnet} + (weight23{subnet}(:,1:nhidden)' * back3{subnet}) .* deriv2{subnet};
end

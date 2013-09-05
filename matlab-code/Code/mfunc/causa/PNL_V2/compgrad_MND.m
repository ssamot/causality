% Compute gradient relative to weights

for subnet=1:ninputs
   for column=1:ninputs
      grad12{subnet}(:,column) = sum(jback2i{subnet,column},2);
      grad23{subnet}(:,1:nhidden) = grad23{subnet}(:,1:nhidden) + jback3{subnet,column} * jacob2o{subnet,column}';
      grad13{subnet}(:,column) = sum(jback3{subnet,column},2);
      grad34{subnet}(:,1) = grad34{subnet}(:,1) + jback4i{subnet,column} * jacob3{subnet,column}';
      grad45{subnet}(:,1:nextra) = grad45{subnet}(:,1:nextra) + jback5{column}(subnet,:) * jacob4o{subnet,column}';
   end
   grad12{subnet} = grad12{subnet} + back2{subnet} * output1';
   grad12{subnet}(:,1:ninputs) = grad12{subnet}(:,1:ninputs) + wdecayf12 * weight12{subnet}(:,1:ninputs);
   grad23{subnet} = grad23{subnet} + back3{subnet} * output2{subnet}';
   grad23{subnet}(:,1:nhidden) = grad23{subnet}(:,1:nhidden) + wdecayf23 * weight23{subnet}(:,1:nhidden);
   grad13{subnet} = grad13{subnet} + back3{subnet} * output1';
   grad34{subnet} = grad34{subnet} + back4{subnet} * output3{subnet}';
   grad34{subnet}(:,1) = grad34{subnet}(:,1) + wdecayf34 * weight34{subnet}(:,1);
end   

% with the MND regularization! The regularization coefficient is lambda
for subnet=1:ninputs
    K{subnet} = cal_K(output3{subnet}(1,:),output1(1:ninputs,:));
    grad23{subnet} = K{subnet} * output2{subnet}' * lambda + grad23{subnet};
    grad13{subnet} = K{subnet} * output1' * lambda +grad13{subnet} ;
    for i = 1:ntrain
        grad12{subnet} = diag(g_dev1_2pi_atan(input2{subnet}(:,i))) * weight23{subnet}(:,1:nhidden)'*K{subnet}(i)*output1(:,i)' * lambda + grad12{subnet};
    end    
end
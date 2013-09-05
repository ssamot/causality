
%post-processing
%assume we have separdata, icasig_noise, s, and s_noise

mixeddata = trpattern; processdata;

T = length(trpattern);
y = [];
for subnet = 1:ninputs
    y = [y; output3{subnet}(1,:)];
end
% %disp(['P3 at convergence is ' num2str(sum(diag((trpattern*y_1'/ntrain)* diag(1./diag(y_1*y_1'/ntrain)) *( y_1*trpattern'/T))))]);
% ['P3 at convergence is ' num2str(sum(diag((trpattern*y_1'/ntrain)* diag(1./diag(y_1*y_1'/ntrain)) *( y_1*trpattern'/T))))],
% Astar = trpattern * y_1'/T * inv(y_1*y_1'/T),
% disp(['MSE at convergence is ' num2str(sum(diag( (trpattern-Astar*y_1)*(trpattern-Astar*y_1)'/T )))]),

% calculate the error between the original sources and the outputs
% first one, squre error
% figure(4),
separdata = separdata - mean(separdata')'*ones(1,ntrain);
separdata = diag(1./std(separdata')) * separdata;
if exist('s') & min(size(s)==size(trpattern))
    for i=1:ninputs
        [Vmax, Imax] = max(abs(s(i,:)*separdata'));
        % calculated by MSE
        Y_i = separdata(Imax,:);
        Y_i_1 = [Y_i; ones(1,T)];
        AB = inv(Y_i_1 * Y_i_1') * Y_i_1 * s(i,:)';
        se_s_y(i) = (s(i,:) - AB' * Y_i_1) * s(i,:)'/T /var(s(i,:));
        figure(4), subplot(ninputs,2,2*i-1),
        plot(s(i,:), Y_i, '.'), title(['s_' int2str(i) ' vs y_' int2str(i) ' (Err = ' num2str(-10*log10(se_s_y(i))) ')']);
        % second one, square error after emilination trivial nonlinear
        % transformations
        net = newff([min(Y_i)-std(Y_i)/10 max(Y_i)+std(Y_i)/10],[8 1],{'tansig' 'purelin'});
        net.trainParam.epochs = 80;
        net = train(net,Y_i,s(i,:));
        Y_s(i,:) = sim(net,Y_i);
        se_s_ys(i) = var(s(i,:) - Y_s(i,:))/var(s(i,:));
        % % [s_sort, s_I] = sort(s(i,:));
        % % [y_sort, y_I] = sort(Y_i);

        figure(4), subplot(ninputs,2,2*i),
        plot(s(i,:), Y_s(i,:), '.'), title(['s_' int2str(i) ' vs f(y_' int2str(i) ')' ' (Err = ' num2str(-10*log10(se_s_ys(i))) ')']);
    end
    se_s_y_all = sum(se_s_y);
    se_s_ys_all = sum(se_s_ys);
    fprintf('SE between s and y:');
    disp([num2str(se_s_y) ' & ' num2str(se_s_y_all)]);
    fprintf('SE between s and tau(y) (after component-wise nonlinearity eliminated):');
    disp([num2str(se_s_ys) ' & ' num2str(se_s_ys_all)]);
    SNR = [-10*log10(se_s_y) -10*log10(se_s_ys)];
    fprintf('SNR of y:');
    disp(SNR(1:ninputs)),
    fprintf('SNR of tau(y):');
    disp(SNR(ninputs+1:2*ninputs)),
    % figure, plot(SE), title(['\lambda = ' num2str(lamda)]), ylabel('SE'), xlabel('Iteration')
else
    SNR = [];
end

% to creat the stucture net
net =  struct('weight12',weight12, 'weight13',weight13, 'weight23',weight23, 'weight34',...
    weight34, 'weight45',weight45);

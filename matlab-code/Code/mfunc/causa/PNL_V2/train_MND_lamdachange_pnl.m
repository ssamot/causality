% Train a net

% % % figure(1), clf
% % %    a1 = axes('position',[.03,.1,.29,.85]);
% % %    a2 = axes('position',[.36,.56,.29,.38]);
% % %    a3 = axes('position',[.69,.56,.29,.38]);
% % %    a4 = axes('position',[.69,.1,.29,.38]);
% % %    a5 = axes('position',[.36,.1,.29,.38]);
   
cost_back = [];
lambda_back = lambda;
% lambda_large = 5; % 5
if Linear_init
    lambda_large = 5; % 5
else
    lambda_large = lambda;
end
lambda = lambda_large;
Iter_1 = 50;
Iter_2 = 350;
for epoch=1:nepochs,
    if epoch < Iter_1
        %         lambda = lambda * 0.991;
        %
        if ~mod(epoch,10) | mod(epoch,10)==1
            netinit_during;
            mincost = 1E20;
        end
    else if epoch < Iter_2
            if ~mod(epoch,20) | mod(epoch,20)==1
                if ~mod(epoch,20)
                    lambda = lambda_large + (epoch - Iter_1)*(lambda_back - lambda_large)/(Iter_2 - Iter_1);
                end
                netinit_during;
                mincost = 1E20;
            end
        else if epoch >= Iter_2
                if epoch == Iter_2
                    lambda = lambda_back;
                end
                if ~mod(epoch,50) | mod(epoch,50) == 1
                    netinit_during;
                    mincost = 1E20;
                end
            end
        end
    end

% %     % Now when the network almost converges, we apply the shrinkage penalty
%     if epoch == nepochs-200
%         wdecayf12 = 1;
%         wdecayf23 = 1;
%     end
    doepoch_MND_pnl;
    cost_back = [cost_back cost];

% % %     plotdata_mine_pnl
    epochs = epochs + 1;
    reportresults
end


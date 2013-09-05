function [thresh_1,testS_1,thresh_2,testS_2,fx_1,gy_1,e_1,fx_2,gy_2,e_2] =...
    CauseOrEffect_new(Index)

eval(['load pairs00' int2str(Index) '.txt']);
eval(['pairs01 = pairs00' int2str(Index) ';']);

x1 = pairs01(:,1)';
y1 = pairs01(:,2)';

% if there are too many samples, just select 5000 points
T = length(x1);
if T>5000
    I_tmp = randperm(T);
    x1 = x1(I_tmp(1:5000));
    y1 = y1(I_tmp(1:5000));
end

x = init_preprocess(x1);
y = init_preprocess(y1);

x = x - mean(x);
x = x/std(x);
y = y - mean(y);
y = y/std(y);

% [thresh_1,testS_1,fx_1,gy_1,e_1,net_1] = efficient_PNL_fun(x,y);
[y12_1, net_1, SNR, gy_1, fx_1] = NICA_MND_pnl_noinput([y;x]); % x->y
% they are actually the negative ones...
fx_1 = -fx_1;
e_1 = y12_1(1,:);

% [thresh_2,testS_2,fx_2,gy_2,e_2,net_2] = efficient_PNL_fun(y,x);
[y12_2, net_2, SNR, gy_2, fx_2] = NICA_MND_pnl_noinput([x;y]); % y->x
fx_2 = -fx_2;
e_2 = y12_2(1,:);

figure, subplot(4,2,1), plot(x, y, '.'); title('transformed data');
subplot(4,2,2); plot(x1, y12_1(1,:),'.'); title('estiamted noise (step 1)');
subplot(4,2,3); plot(y1, gy_1, '.'); title('estimated g^{-1}');
subplot(4,2,4); plot(x1, fx_1, '.'); title('estimated f');
subplot(4,2,5); plot(y1, y12_2(1,:),'.'); title('estiamted noise (step 1)');
subplot(4,2,7); plot(x1, gy_2, '.'); title('estimated g^{-1}');
subplot(4,2,8); plot(y1, fx_2, '.'); title('estimated f');

% testing...
fprintf('Performing independence tests...\n');
alpha = 0.01;
if length(x) > 2000
    params.sigx = -1;
    params.sigy = -1;
    if length(x) > 5000
        I_tmp = randperm(length(x));
        % to test if x1 -> x2
        fprintf('For the direction x1->x2:\n');
        [thresh_1,testS_1,params] = hsicTestGamma(e_1(I_tmp(1:5000))',x(I_tmp(1:5000))',alpha,params);
        % to test if x2 -> x1
        fprintf('For the direction x2->x1:\n');
        [thresh_2,testS_2,params] = hsicTestGamma(e_2(I_tmp(1:5000))',y(I_tmp(1:5000))',alpha,params);
    else
        fprintf('For the direction x1->x2:\n');
        % to test if x1 -> x2
        [thresh_1,testS_1,params] = hsicTestGamma(e_1',x',alpha,params);
        % to test if x2 -> x1
        fprintf('For the direction x2->x1:\n');
        [thresh_2,testS_2,params] = hsicTestGamma(e_2',y',alpha,params);
    end
else
    params.shuff = 200;
    params.sigx = -1;
    params.sigy = -1;
    
    % x1 -> x2?
    fprintf('For the direction x1->x2:\n');
    [thresh_1,testS_1] = hsicTestBoot(e_1',x',alpha,params),
    fprintf('For the direction x2->x1:\n');
    [thresh_2,testS_2] = hsicTestBoot(e_2',y',alpha,params),
end
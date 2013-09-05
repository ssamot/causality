clear all;
level=0.01;
count=0;
for r=0.5:0.01:0.8
    count=count+1;
    count
    for i=1:100
        [X Y]=add_noise_cyclic(200, [0;1;2;3], [0.6 0.1 0.1 0.2], [r/2 r/2 0.5-r/2 0.5-r/2]);
        %[X Y]=add_noise(2000, [3;1;2;0], [0.6 0.1 0.1 0.2], [0.55 0.15 0.15 0.15]);
        [fct p fct_bw p_bw]=fit_both_dir_discrete(X,1,Y,1,level,0);        
        if (p>level)&&(p_bw>level)
            res(count,i)=0;
        elseif (p>level)&&(p_bw<level)
            res(count,i)=1;
        elseif (p<level)&&(p_bw>level)
            res(count,i)=-1;
        elseif (p<level)&&(p_bw<level)
            res(count,i)=0;
        end
    end
end
        
ymatrix1=[sum(res'==1);sum(res'==-1)]'/100;
figure1 = figure('XVisual',...
    '0x63 (TrueColor, depth 32, RGB mask 0xff0000 0xff00 0x00ff)');
colormap('gray');

axes1 = axes('Parent',figure1,...
    'XTickLabel',{'-0.2','-0.1','0','0.1','0.2'},...
    'XTick',[1 11 21 31 41],...
    'FontSize',20);

box('on');
hold('all');

% Create multiple lines using matrix input to bar
bar1 = bar(ymatrix1,'BarLayout','stacked','Parent',axes1);
set(bar1(1),'FaceColor',[0 0 0],'DisplayName','correctly classified');
set(bar1(2),'FaceColor',[0.9412 0.9412 0.9412],...
    'DisplayName','wrongly classified');

% Create xlabel
xlabel('r',...
    'FontSize',20);

% Create legend
legend1 = legend(axes1,'show');
set(legend1,'Position',[0.6686 0.7896 0.2224 0.1112]);
        

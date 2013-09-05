% Plot the data

% The plotting window should be resized so that the left-hand and middle plots are square.

% Several types of plots are provided below. Comment and uncomment as you wish.
% You can also edit, e.g. the axes specified for each plot, to change the plot locations

% Axes a1 correspond to the leftmost plot and a2 to the middle plot. Axes a3 and a4
% correspond to two rightmost plots, a3 above a4. Axes a5 correspond
% to a square plot at the rightmost position (same position as a3 and a4).

% You shouldn't normally make more that one plot in each set of axes (a1 to a5).

% Note that axes a3 and a4 occupy the same position as a5. Therefore, if you
% want to use a5 you should comment out the definitions of a3 and a4 and uncomment a5.

if mod(epochs, ndisp)==0
   clf
   a1 = axes('position',[.03,.1,.29,.85]);
   a2 = axes('position',[.36,.56,.29,.38]);
   a3 = axes('position',[.69,.56,.29,.38]);
   a4 = axes('position',[.69,.1,.29,.38]);
   a5 = axes('position',[.36,.1,.29,.38]);
   %a5 = axes('position',[.69,.1,.29,.85]);
   
   figure(1),
   
   % Left:   Scatter plot of separated components
   
   %axes(a1), cla, plot(input3{1}, input3{2}, 'b.'), axis tight
   % NOTE that the axes are changed: especially for pnl causlaity
   % discovery!!!
   axes(a1), cla, plot(output3{2}(1,:), output3{1}(1,:), 'b.'), axis tight
   
   
   % Center: Scatter plot of auxiliary outputs (z)

   axes(a2), cla, plot(output{1}, output{2}, 'b.'), axis equal

   
   % Left:   Scatter plot of mixture components
   
   %axes(a1), cla, plot(trpattern(1,:), trpattern(2,:), 'b.'), axis tight
    
   
   % Center: Separated component 1 versus source 1
   
   %axes(a2), cla, plot(aux(1,:),output3{1}(1,:),'b.'),axis tight
   
   
   % Right:  Separated component 2 versus source 2
   
   %axes(a5), cla, plot(aux(2,:),output3{2}(1,:),'b.'),axis tight
   
   
   % Center: Separated component 1 versus source 2
   
   %axes(a2), cla, plot(aux(2,:),output3{1}(1,:),'b.'),axis tight
   
   
   % Right:  Separated component 2 versus source 1
   
   %axes(a5), cla, plot(aux(1,:),output3{2}(1,:),'b.'),axis tight  
   
   
   % Right:  Cumulative probability functions learned by the output MLPs
   %         Note: These are scaled between -1 and 1, instead of between 0 and 1
   
   compdist
   axes(a3), cla, plot(cgrid{1}, output_p{1}, 'b-'), axis tight
   axes(a4), cla, plot(cgrid{2}, output_p{2}, 'b-'), axis tight 
   
end
axes(a5), %cla,  
plot(epoch, cost, 'b*'), axis tight, hold on

pause(0)  % This is needed in Windows, to display the plots
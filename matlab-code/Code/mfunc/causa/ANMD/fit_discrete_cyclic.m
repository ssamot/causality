function [fct, p_val]=fit_discrete(X,Y,level,doplots,dir)

%%%%%%%%%%
%parameter
%%%%%%%%%%
num_iter=10;
num_pos_fct=min(max(Y)-min(Y),10);

%rescaling: 
%X_new takes values from 1...X_new_max
%Y_values are everything between Y_min and Y_max
[X_values aa X_new]=unique(X);
Y_values=min(Y):1:max(Y);Y_values=Y_values';

%compute common zaehldichte
%for i=1:length(X_values)
%    for j=1:length(Y_values)
%        p(i,j)=sum((X==X_values(i)).*(Y==Y_values(j)));
%    end
%end

if size(X_values,1)==1|size(Y_values,1)==1
    fct=ones(length(X_values),1)*Y_values(1);
    p_val=1;
%    display('okokokokokoko')
else
    p=hist3([X Y], {X_values Y_values});
    %[Y_values'; p]

    fct=[];
    for i=1:length(X_values)
        [a b]=sort(p(i,:));
        for k=1:size(p,2)
            if k~=b(length(b))
                p(i,k)=p(i,k)+1/(2*abs(k-b(length(b))));
            else
                p(i,k)=p(i,k)+1;
            end
        end
        [a b]=sort(p(i,:));
        cand{i}=b;
        fct=[fct;Y_values(b(length(b)))];
    end

    yhat=fct(X_new);
    eps=mod(Y-yhat,max(Y)-min(Y)+1);
    p_val=chi_sq_quant(eps,X,length(unique(eps)),length(X_values));
    if doplots==1
        display(['fitting ' int2str(dir+1) '. direction']);
        figure(dir+1);
        plot_fct_dens_cyclic(X, X_values, X_new, Y, Y_values, fct, p_val, level, dir,1);
        pause
    end
    i=0;
    while (p_val<level) & (i<num_iter)
        for j_new=randperm(length(X_values))
            for j=1:(num_pos_fct+1)
                pos_fct{j}=fct;
                pos_fct{j}(j_new)=Y_values(cand{j_new}(length(cand{j_new})-(j-1)));
                yhat=pos_fct{j}(X_new);
                eps=mod(Y-yhat,max(Y)-min(Y)+1);
                [p_val_comp(j) p_val_comp2(j)]=chi_sq_quant(eps,X,length(unique(eps)),length(X_values));
            end
    %        [p_val_comp;p_val_comp2]
            %[aa j_max]=min(p_val_comp2);
            [aa j_max]=max(p_val_comp);
            if aa<1e-3
                [aa j_max]=min(p_val_comp2);
            end
            fct=pos_fct{j_max};    
            yhat=fct(X_new);
            eps=mod(Y-yhat,max(Y)-min(Y)+1);
            p_val=chi_sq_quant(eps,X,length(unique(eps)),length(X_values));
            if doplots==1
                display(['fitting ' int2str(dir+1) '. direction']);
                figure(dir+1);
                plot_fct_dens_cyclic(X, X_values, X_new, Y, Y_values, fct, p_val, level, dir,1);
            end
        end
        i=i+1;
    end
    %fct=fct+round(mean(eps));
    if doplots==0.5
        figure(dir+1);
        plot_fct_dens_cyclic(X, X_values, X_new, Y, Y_values, fct, p_val, level, dir,0);
    end
end
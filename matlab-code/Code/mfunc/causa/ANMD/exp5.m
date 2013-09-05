get_tage;tage=mod(1:10000,365)';
get_temp;
counter=0;
for i=500:500:9500
    counter=counter+1
    if i==9500
        i=9162;
    end
     [fct_fw_monate, p_fw_monate(counter)]=fit_discrete(monate(1:i),round(1*temp(1:i)),0.0001,0,1);
     [fct_bw_monate, p_bw_monate(counter)]=fit_discrete_cyclic(round(1*temp(1:i)),monate(1:i),0.0001,0,1);
%    [fct_fw_monate10, p_fw_monate10(counter)]=fit_discrete(monate(1:i),round(10*temp(1:i)),0.0001,0,1);
%    [fct_bw_monate10, p_bw_monate10(counter)]=fit_discrete_cyclic(round(10*temp(1:i)),monate(1:i),0.0001,0,1);
end
plot(p_fw_monate,'x');
hold on
plot(p_bw_monate,'o');
hold off
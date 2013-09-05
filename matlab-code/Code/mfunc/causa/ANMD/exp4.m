%X should be a vector 4177x1 containing the sex of abalone (0,1 or 2)
%abalone should be a 4177x9 matrix, containing length, diameter and height
%     of abalone (in mm) as cols 2,3,4.
%
%

load('abalone')
%
counter=0;
for i=1000:500:1000
    counter=counter+1;
    if i==0
        i=100;
    elseif i==4500
        i=4177;
    end
    [fct_fw, p1(counter), fct_bw, p_bw1(counter)]=fit_both_dir_discrete(abalone(1:i,1),0,round(100*abalone(1:i,2)),0,0.01,0);
    [fct_fw, p2(counter), fct_bw, p_bw2(counter)]=fit_both_dir_discrete(abalone(1:i,1),0,round(100*abalone(1:i,3)),0,0.01,0);
    [fct_fw, p3(counter), fct_bw, p_bw3(counter)]=fit_both_dir_discrete(abalone(1:i,1),0,round(100*abalone(1:i,4)),0,0.01,0);
    [fct_bw_cyc, p_bw1_cyc(counter)]=fit_discrete_cyclic(round(100*abalone(1:i,2)),abalone(1:i,1),0.01,0,1);
    [fct_bw_cyc, p_bw2_cyc(counter)]=fit_discrete_cyclic(round(100*abalone(1:i,3)),abalone(1:i,1),0.01,0,1);
    [fct_bw_cyc, p_bw3_cyc(counter)]=fit_discrete_cyclic(round(100*abalone(1:i,4)),abalone(1:i,1),0.01,0,1);
end

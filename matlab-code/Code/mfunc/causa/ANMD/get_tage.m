monate=[];
for i=0:1000
if mod(i,12)<7
monate=[monate;i*ones(30,1)];
else
monate=[monate;i*ones(31,1)];
end
end
monate=mod(monate,12);

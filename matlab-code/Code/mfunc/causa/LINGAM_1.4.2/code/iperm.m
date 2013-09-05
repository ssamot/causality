function q = iperm( p )
   
for i=1:length(p)
   q(i) = find(p==i); 
end


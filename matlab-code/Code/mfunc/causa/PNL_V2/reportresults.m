% Report training results at end of epoch
fpd=0; %IG change t 2 to see the results
if ~mod(epochs, 100)
    dprintf(fpd,'cost = %11.8f,  improvement = %11.8f,  epoch %5i\n',cost, mincost-cost, epochs)
end

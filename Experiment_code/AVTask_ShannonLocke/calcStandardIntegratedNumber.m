rate = 8;
fps = 60; 
dur = 2;
nOff = 2;
tStep = (nOff + 1)/fps;
seqOpt = 0;
iter = 10000;

integrated = 0;
for ii = 1:iter
    [~,a] = oneStreamAV_PoissonProcess(rate,dur,tStep,1,nOff,seqOpt);
    [~,v] = oneStreamAV_PoissonProcess(rate,dur,tStep,1,nOff,seqOpt);
    [MO,~,~] = get_maxOffset(v,a,fps);
    if MO < 0.103; integrated = integrated + 1; end
end

propInt = integrated/iter;
disp('The proportion of integrated sequences:')
disp(propInt)
lambda = 2.5;
dur = 100;
tStep = 2/60;
N = 1000;

figure; hold on
for ii = 1:length(lambda)
events = makePoissonProcess(lambda(ii),1,dur,tStep,N);
events = sum(events)/dur;
disp(mean(events))
hist(events,50)
% [counts,centers] = hist(events,50);
% plot(centers,counts,'k-')
% plot(centers-mean(centers),counts,'k-')
end
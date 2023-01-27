%% CUE CONFLICT EXAMPLE
x = -10:0.05:10; x=x';
sA = 1;
sV = 2;
sAV = sqrt(1/(1/sA^2 + 1/sV^2));
mA = -4;
mV = 3;
w = (1/sA^2) / (1/sA^2 + 1/sV^2);
mAV = w*mA + (1-w)*mV;
yA = normpdf(x,mA,sA);
yV = normpdf(x,mV,sV);
yAV = normpdf(x,mAV,sAV);
plot(x,yA,x,yV,x,yAV)

%% SENSITIVITY EXAMPLE
sA = 2.5;
sV = 3;
sAV = sqrt(1/(1/sA^2 + 1/sV^2));
yA2 = normpdf(x,0,sA);
yV2 = normpdf(x,0,sV);
yAV2 = normpdf(x,0,sAV);
plot(x,yA2,x,yV2,x,yAV2)

%% PSYCHOMETRIC FUNCTION EXAMPLE
PFA = normcdf(x,0,sA);
PFV = normcdf(x,0,sV);
PFAV = normcdf(x,0,sAV);
plot(x,PFA,x,PFV,x,PFAV)

%% EXPORT DATA:
T = table(x,yA,yV,yAV,yA2,yV2,yAV2,PFA,PFV,PFAV);
savefile = [cd '/dataCueComb.txt'];
writetable(T,savefile,'Delimiter',' ')
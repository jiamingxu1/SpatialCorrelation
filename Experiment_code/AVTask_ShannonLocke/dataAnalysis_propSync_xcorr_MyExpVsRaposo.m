% This script will compare the following sequence statistics of Raposo et 
% al. (2012) and my AVRD exp: 1) proportion of synchronous events, 2) the
% mean cross-correlograms. This will be done with respect to event rate.

%% Get Data:

% Get the simulation data:
load('MyExpVsRaposo')

% General information for simulation:
rate = [4 6 8 10 12 14];
nRate = length(rate);
N = 1000;

%% Proportion synchronous by rate:

close All; 
rval = 0.1; % value for binning
figure;
for ii = 1:2 % EACH simulation
    switch ii
        case 1 % my experiment
            X = ps;
            titleText = 'My Exp: ';
        case 2 % raposo's
            X = psRaposo;
            titleText = 'Raposo: ';
    end
    subplot(2,1,ii); hold on 
    col = gradCustColBar(nRate, rate, [0 0 1], [1 0 0]);
   for jj = 1:nRate % EACH rate value
       [x,f,p] = freqTable(X(:,jj),rval);
       plot(x,p,'-o','Color',col(jj,:));
   end
   xlabel('Proportion Synchronous'); xlim([0,0.8])
   ylabel('Percent of Trials'); ylim([0,0.7])
   title([titleText '% Sync trials by rate'])
end

% Export data to Latex for plotting:
[x,f,p] = freqTable(X,0.1);
p = p * (1/max(p(:)));
y4 = p(:,1);
y6 = p(:,2);
y8 = p(:,3);
y10 = p(:,4);
y12 = p(:,5);
y14 = p(:,6);
T = table(x,y4,y6,y8,y10,y12,y14);
writetable(T,'histPropSync','Delimiter',' ')

%% Mean Cross-correlograms:
% Mean peak correlation between +/-200ms

idx_lag = (size(cc,1)-1)/2;
idx_lag = -idx_lag:1:idx_lag;
keepMine = abs(idx_lag) <= 12;
keepRaposo = abs(idx_lag) <= 20;
maxCorrMine = squeeze(max(cc(keepMine,:,:),[],1))';
maxCorrRaposo = squeeze(max(ccRaposo(keepRaposo,:,:),[],1))';
meanMine = mean(maxCorrMine);
meanRaposo = mean(maxCorrRaposo);
sdMine = std(maxCorrMine);
sdRaposo = std(maxCorrRaposo);
T = table(rate',meanMine',meanRaposo',sdMine',sdRaposo');
writetable(T,'seqCorrSimResults.txt','Delimiter',' ')
 
%%

% Single example (to show the peakiness in Raposo et al.'s stimuli):
figure;
for ii = 1:2 % EACH simulation
    switch ii
        case 1 % my experiment
            X = cc;
            titleText = 'My Exp: ';
        case 2 % raposo's
            X = ccRaposo;
            titleText = 'Raposo: ';
    end
    subplot(2,1,ii); hold on 
   for jj = 4 % Choose 10 events/s
       y = X(:,jj,10);
       plot(lag,y,'-ko')
   end
   xlabel('Lag (sec)'); xlim([-0.2,0.2])
   ylabel('cross-correlation'); ylim([-0.2,1.1])
   title([titleText 'example xcorr of 10 events/s seq'])
end

% Get mean cross-correlograms:
cc = nanmean(cc,3);
ccRaposo = nanmean(ccRaposo,3);

% Lag indices:
idx_lag = (size(cc,1)-1)/2;
idx_lag = -idx_lag:1:idx_lag;
        
% Visualise:
figure;
for ii = 1:2 % EACH simulation
    switch ii
        case 1 % my experiment
            X = cc;
            lag = (1/60) * idx_lag;
            smoothingKernal = gausswin(3); % 80 ms = 25, 10 ms = 3
            titleText = 'My Exp: ';
        case 2 % raposo's
            X = ccRaposo;
            lag = (1/100) * idx_lag;
            smoothingKernal = gausswin(7); % 80 ms = 41, 12 ms = 7
            titleText = 'Raposo: ';
    end
    smoothingKernal = smoothingKernal / sum(smoothingKernal);
    subplot(2,1,ii); hold on 
    col = gradCustColBar(nRate, rate, [0 0 1], [1 0 0]);
   for jj = 1:nRate % EACH rate value
       y = conv(X(:,jj), smoothingKernal, 'same');
       plot(lag,y,'-','Color',col(jj,:));
   end
   xlabel('Lag (sec)'); xlim([-0.2,0.2])
   ylabel('cross-correlation'); ylim([-0.15,0.15])
   title([titleText 'mean xcorr by rate'])
end
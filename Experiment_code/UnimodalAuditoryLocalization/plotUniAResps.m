% This script plots histograms for the unimodal localization responses
clear all; close all; clc; rng(1);

%% load and organize data
subjN    = 2;
subjI    = 'ZL';
addpath(['/Users/oliviaxujiaming/Desktop/GitHub/SpatialCorrelation/Experiment_code/UnimodalAuditoryLocalization/Pilot/',subjI]);
C               = load(['UniAlocalization_sub', num2str(subjN), '.mat']);
nRep            = C.UniAlocalization_data{1}.nRep;
nAudFile        = C.UniAlocalization_data{1}.nAudFile;
nTrial          = C.UniAlocalization_data{1}.nTrial;
loc             = C.UniAlocalization_data{1}.actualAud; % 21 locations
data            = C.UniAlocalization_data{1}.result; %(:,1) actualLoc, (:,2) locResponses
meanLocResp_A   = NaN(1, nAudFile);

%% Plot localization responses
close all
figure
hold on
muLocResp = zeros(nAudFile,1);
for ii = 1:nAudFile
   scatter(loc(ii),data(abs(data(:,1)-loc(ii))<1e-3,2),20,'filled')    
   muLocResp(ii) = mean(data(abs(data(:,1)-loc(ii))<1e-3,2));
end
plot(loc,muLocResp,'Linewidth',3)
set(gca,'XTick',-18:1.8:18)
xlim([-20 20])
ylim([min(data(:,2))-3 max(data(:,2))+3])
xlabel('Actual auditory locations (dvg)')
ylabel('Localization responses (dvg)')
title('Sub2 ZL')

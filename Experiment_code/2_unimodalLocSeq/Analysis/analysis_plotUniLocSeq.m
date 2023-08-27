%% analysis for unimodal sequence localization 

clear all; close all; clc

% load the data
subjNum                  = 5;
subjInitial              = 'ZD';
addpath(genpath(['/e/3.3/p3/hong/Desktop/GitHub/SpatialCorrelation/'...
    'Experiment_code/2_unimodalLocSeq/Analysis/',subjInitial,'/']));
C                        = load(strcat('UnimodalLocSeq_sub', num2str(subjNum),'.mat'));
ExpInfo                  = C.Unimodal_localization_data{1};
ScreenInfo               = C.Unimodal_localization_data{2};
VSinfo                   = C.Unimodal_localization_data{3};
AudInfo                  = C.Unimodal_localization_data{4};
centroids                = ExpInfo.centroids;

% auditory data
% 1st row: actural centroid (in deg)
% 2nd row: responses (in deg)
% 3rd row: response time
Acentroids               = AudInfo.data(1,:);
Aresponses               = AudInfo.data(2,:);
Aseqs_sampled            = AudInfo.randSampleAtrain;

% visual data
% 1st row: target centroid (in deg)
% 2nd row: target centroid (in cm)
% 3rd row: response (in deg)
% 4th row: response time
Vcentroids               = VSinfo.data(1,:);
Vresponses               = VSinfo.data(3,:);
Vseqs_sampled            = VSinfo.randSampleVtrain;

%% plot localization responses
% auditory localization
figure(1);
hold on
ALocResp_mu = zeros(length(centroids),1);
ALocResp_sd = zeros(length(centroids),1);
for ii = 1:length(centroids)
   scatter(AudInfo.data(1,abs(AudInfo.data(1,:)-centroids(ii))<1e-3),...
       AudInfo.data(2,abs(AudInfo.data(1,:)-centroids(ii))<1e-3),20,'filled')    
   ALocResp_mu(ii) = mean(AudInfo.data(2,abs(AudInfo.data(1,:)-centroids(ii))<1e-3));
   ALocResp_sd(ii) = std(AudInfo.data(2,abs(AudInfo.data(1,:)-centroids(ii))<1e-3));
end
plot(centroids,ALocResp_mu,'Linewidth',2,'Color','k')
plot(-24:1:24,-24:1:24,"--",'Color','k')
set(gca,'XTick',-24:10:26)
xlim([-30 30])
ylim([min(AudInfo.data(2,:))-3 max(AudInfo.data(2,:))+3])
xlabel('Actual auditory centroid locations (dvg)','FontSize', 12)
ylabel('Localization responses (dvg)','FontSize', 12)
title('Unimodal auditory sequence localization (sub subjI)','FontSize', 14)

% visual localization
figure(2);
hold on
VLocResp_mu = zeros(length(centroids),1);
VLocResp_sd = zeros(length(centroids),1);
for ii = 1:length(centroids)
   scatter(VSinfo.data(1,abs(VSinfo.data(1,:)-centroids(ii))<1e-3),...
       VSinfo.data(3,abs(VSinfo.data(1,:)-centroids(ii))<1e-3),20,'filled')    
   VLocResp_mu(ii) = mean(VSinfo.data(3,abs(VSinfo.data(1,:)-centroids(ii))<1e-3));
   VLocResp_sd(ii) = std(VSinfo.data(3,abs(VSinfo.data(1,:)-centroids(ii))<1e-3));
end
plot(centroids,VLocResp_mu,'Linewidth',2,'Color','k')
plot(-24:1:24,-24:1:24,"--",'Color','k')
set(gca,'XTick',-24:10:26)
xlim([-30 30])
ylim([min(VSinfo.data(3,:))-3 max(VSinfo.data(3,:))+3])
xlabel('Actual visual centroid locations (dvg)','FontSize', 12)
ylabel('Localization responses (dvg)','FontSize', 12)
title('Unimodal visual sequence localization (sub subjI)','FontSize', 14)


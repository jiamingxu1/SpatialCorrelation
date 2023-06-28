% Analysis for bimodal localization and unity judgment task

%% select output 
clear all; close all; clc
subjN_dict = [2,3,4];
subjI_dict = {'JX','HHL','ZGL'};

% create popout window
prompt     = {'Subject ID:','Plot unity judgment (1:yes; 0: no):',...
                'Plot demeand locR:', 'Plot mean locR:',...
                'save data', 'export a table for unityJdg', ...
                'export a table for locR:', 'export a table for locR (abs(spatialD)):'};
dlgtitle   = 'Input';
dims       = [1 35];
definput   = {'2','0','0','0','1','0','0','0'};
answer     = inputdlg(prompt,dlgtitle,dims,definput);
bool_plt   = arrayfun(@(idx) str2double(answer(idx)), 2:4); 
bool_save  = arrayfun(@(idx) str2double(answer(idx)), 5:length(prompt)); 

%% load bimodal data
subjN = str2double(answer(1));
subjI = subjI_dict{find(subjN==subjN_dict,1)};
addpath(genpath(['/Users/oliviaxujiaming/Desktop/Github/SpatialCorrelation/',...
    'Experiment_code/3_bimodalLocUnity/Analysis/', subjI]));

% Create condition matrices and data matrices
% A centroid       : A centroid location for a given trial (in deg)
% V centroid       : V centroid location for a given trial (in deg)
% disc             : discrepancy between the AV pair (V-A)
% corr             : correlation between the AV pair
% localizeModality : cued modality after stimulus presentation (1: A, 2, V)
% locResp          : localization responses (in deg)
% unityResp        : reported common-cause judgment (1: C=1, 2: C=2)

[Acentroid_idx,Vcentroid_idx,disc,corr,localizeModality,locResp,unityResp]...
                               = deal(NaN(2, 500)); % 500 = nTT/2

% load conditions and data files                    
for i = 1:2 % session 1-2
    C = load(['BimodalLocSeq_','sub', num2str(subjN),...
    '_session',num2str(i),'.mat']);
    Acentroid_idx(i,:)         = C.Bimodal_localization_data{1,5}...
                                  .trialConditions(1,:); % A centroid idx
    Vcentroid_idx(i,:)         = C.Bimodal_localization_data{1,5}...
                                  .trialConditions(2,:); % V centroid idx
    disc(i,:)                  = C.Bimodal_localization_data{1,5}...
                                  .trialConditions(3,:);
    corr(i,:)                  = C.Bimodal_localization_data{1,5}...
                                  .trialConditions(4,:);            
    localizeModality(i,:)      = C.Bimodal_localization_data{1,5}...
                                  .AVlocTrialOrder; % 1=A; 2=V 
    locResp(i,:)               = C.Bimodal_localization_data{1,5}...
                                  .localization;                     
    unityResp(i,:)             = C.Bimodal_localization_data{1,5}...
                                  .unity;             
end

% load experiment information
ExpInfo     = C.Bimodal_localization_data{1,1};
sessions    = [1 2];
lenS        = length(sessions);
modality    = {'A','V'};
lenM        = length(modality);
disc_levels = ExpInfo.disc;
lenD        = length(disc_levels);
corr_levels = ExpInfo.corrVals;
lenC        = length(corr_levels);
numReps     = ExpInfo.numReps;
nTT         = lenS*lenD*lenC*numReps; % 5*5 = 25 different AV pairs, each pair was repeated 40 times

% Acentroid = [ExpInfo.centroids(Acentroid_idx(1,:)) ExpInfo.centroids(Acentroid_idx(2,:))];
% Vcentroid = [ExpInfo.centroids(Vcentroid_idx(1,:)) ExpInfo.centroids(Vcentroid_idx(2,:))];
% disc      = [disc_temp(1,:) disc_temp(2,:)];
% corr      = [corr_temp(1,:) corr_temp(2,:)];
% 
% % re-organize data matrices
% localizeModality = [localizeModality_temp(1,:) localizeModality_temp(2,:)];
% locResp          = [locResp_temp(1,:) locResp_temp(2,:)];
% unityResp        = [unityResp_temp(1,:) unityResp_temp(2,:)];
                        
%% load unimodal data
addpath(genpath(['/Users/oliviaxujiaming/Desktop/Github/SpatialCorrelation/',...
    'Experiment_code/2_unimodalLocSeq/Analysis/', subjI])); 
D = load(strcat('UnimodalLocSeq_sub', num2str(subjN),'.mat'));
VSinfo_uni               = D.Unimodal_localization_data{3};
AudInfo_uni              = D.Unimodal_localization_data{4};
centroids                = ExpInfo.centroids;

% auditory data
% 1st row: actural centroid (in deg)
% 2nd row: responses (in deg)
% 3rd row: response time

% visual data
% 1st row: target centroid (in deg)
% 2nd row: target centroid (in cm)
% 3rd row: response (in deg)
% 4th row: response time

% compute the mean unimodal localization responses
meanLocA_uni = arrayfun(@(idx) mean(AudInfo_uni.data(2,abs(AudInfo_uni.data(1,:) - ...
                    centroids(idx)) < 1e-3)), 1:length(centroids));
meanLocV_uni = arrayfun(@(idx) mean(VSinfo_uni.data(3,abs(VSinfo_uni.data(1,:) - ...
                    centroids(idx)) < 1e-3)), 1:length(centroids));
meanLoc_uni   = {meanLocA_uni, meanLocV_uni};

%% organize data matrices
% initialize data matrices
% unityMat  : stores common-cause judgments
%            2 (conditions) x 2 (phases) x 4 (A locations) x 4 (V locations) x 20 (trials)
% pC1_resp  : stores the percentage of C = 1 responses for each AV pair
%            2 (conditions) x 2 (phases) x 4 (A locations) x 4 (V locations)
% locRespMat: stores the localization responses
%            2 (conditions) x 2 (phases) x 4 (A locations) x 4 (V locations)
%                           x 2 (localization modality) x 10 (trials)
unityMat   = NaN(lenC, lenP, length(A_loc), length(V_loc), nT_perPair*lenM);
pC1_resp   = NaN(lenC, lenP, length(A_loc), length(V_loc));
locRespMat = NaN(lenC, lenP, length(A_loc), length(V_loc), lenM, nT_perPair); 













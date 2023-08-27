% Group-level behavioral results for unity and VE

clear all; clc;
subjN = [2,3,4,5,7,8,9,10,11];
subjI = {'JX','HHL','ZGL','ZD','YX','DT','TA','MD','BY'};

for i = 1:length(subjN)
    addpath(genpath(['/Users/oliviaxujiaming/Desktop/Github/SpatialCorrelation/',...
        'Experiment_code/3_bimodalLocUnity/Analysis/', subjI{i}]));
end

% Create condition matrices and data matrices
% A centroid       : A centroid location for a given trial (in deg)
% V centroid       : V centroid location for a given trial (in deg)
% disc             : discrepancy between the AV pair (V-A)
% corr             : correlation between the AV pair
% localizeModality : cued modality after stimulus presentation (1: A, 2, V)
% locResp          : localization responses (in deg)
% unityResp        : reported common-cause judgment (1: C=1, 2: C=2)


% initialize data structs to store data for each subject
indData = struct('C', []);
groupData = repmat(indData, length(subjN), 1);

[Acentroid_idx,Vcentroid_idx,disc_temp,corr_temp,locModality_temp,locResp_temp,unityResp_temp]...
                               = deal(NaN(2, 400)); % nTT/2

for j = 1:length(subjN)
    for i = 1:2
        groupData(j).C = load(['BimodalLocSeq_','sub', num2str(subjN(j)),...
        '_session',num2str(i),'.mat']);
     
        Acentroid_idx(i,:)              = C.Bimodal_localization_data{1,5}...
                                      .trialConditions(1,:); % A centroid idx
        Vcentroid_idx(i,:)              = C.Bimodal_localization_data{1,5}...
                                      .trialConditions(2,:); % V centroid idx
        disc_temp(i,:)                  = C.Bimodal_localization_data{1,5}...
                                      .trialConditions(3,:);
        corr_temp(i,:)                  = C.Bimodal_localization_data{1,5}...
                                      .trialConditions(4,:);            
        locModality_temp(i,:)           = C.Bimodal_localization_data{1,5}...
                                      .AVlocTrialOrder; % 1=A; 2=V 
        locResp_temp(i,:)               = C.Bimodal_localization_data{1,5}...
                                      .localization;                     
        unityResp_temp(i,:)             = C.Bimodal_localization_data{1,5}...
                                      .unity;    
    end
end


%% load experiment information
ExpInfo     = C.Bimodal_localization_data{1,1};
sessions    = [1 2];
lenS        = length(sessions);
modality    = {'A','V'};
lenM        = length(modality);
disc_levels = ExpInfo.disc;
lenD        = length(disc_levels);
centroids   = ExpInfo.centroids;
lenCent     = length(centroids);
corr_levels = ExpInfo.corrVals;
lenCorr     = length(corr_levels);
numReps     = ExpInfo.numReps;
nTT         = lenS*lenD*lenCorr*numReps; % 5*5 = 25 different AV pairs, each pair was repeated 40 times

Acentroid = [ExpInfo.centroids(Acentroid_idx(1,:)) ExpInfo.centroids(Acentroid_idx(2,:))];
Vcentroid = [ExpInfo.centroids(Vcentroid_idx(1,:)) ExpInfo.centroids(Vcentroid_idx(2,:))];
disc      = [disc_temp(1,:) disc_temp(2,:)];
corr      = [corr_temp(1,:) corr_temp(2,:)];

% re-organize data matrices
locModality      = [locModality_temp(1,:) locModality_temp(2,:)];
locResp          = [locResp_temp(1,:) locResp_temp(2,:)];
unityResp        = [unityResp_temp(1,:) unityResp_temp(2,:)];



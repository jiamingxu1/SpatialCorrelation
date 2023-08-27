% Group-level behavioral results for unity judgement and VE

clear all; clc;
subjN = [2,3,4,5,7,8,9,10,11];
subjI = {'JX','HHL','ZGL','ZD','YX','DT','TA','MD','BY'};

for i = 1:length(subjN)
    addpath(genpath(['/Users/jiamingxu/Desktop/Github/SpatialCorrelation/',...
        'Experiment_code/3_bimodalLocUnity/Analysis/', subjI{i}]));
end

% load data for each subject into a data struct 'groupData' (rows = individual
% subjects, cols = session 1, session 2)
indData = struct('session1',[],'session2',[]);
groupData = repmat(indData, length(subjN), 1);
for j = 1:length(subjN)   
    groupData(j).session1 = load(['BimodalLocSeq_','sub', num2str(subjN(j)),...
    '_session',num2str(1),'.mat']);
    groupData(j).session2 = load(['BimodalLocSeq_','sub', num2str(subjN(j)),...
    '_session',num2str(2),'.mat']);
end

% load some experiment information
sessions    = [1 2];
lenS        = length(sessions);
modality    = {'A','V'};
lenM        = length(modality);
disc_levels = [-20 -10 0 10 20];
lenD        = length(disc_levels);
centroids   = [-24 -14 -4 6 16 26];
lenCent     = length(centroids);
corr_levels = -1:0.5:1;
lenCorr     = length(corr_levels);
numReps     = 40; %40 for subj 1 and 2; 32 for the rest
nTT         = lenS*lenD*lenCorr*numReps;

% organize data into a big matrix 
% 1. subjN            : subject ID
% 2. A centroid       : A centroid location for a given trial (in deg)
% 3. V centroid       : V centroid location for a given trial (in deg)
% 4. disc             : discrepancy between the AV pair (V-A)
% 5. corr             : correlation between the AV pair
% 6. localizeModality : cued modality after stimulus presentation (1: A, 2, V)
% 7. locResp          : localization responses (in deg)
% 8. unityResp        : reported common-cause judgment (1: C=1, 2: C=2)

% first get subject data, and then later concatenate 
VE_ujdg_ind = cell(length(subjN),1); % pre-allocate
for i = 1:length(subjN)
    if i == 1 || i == 2
        VE_ujdg_ind{i} = NaN(1000,10);
    else
        VE_ujdg_ind{i} = NaN(800,10);
    end
end 

sessionData = cell(1, 2); % 2 sessions per subject, this gets updated for each i loop
for i = 1:length(subjN)
    if i == 1 || i == 2
        sessionData(:) = {NaN(500, 10)};
    else
        sessionData(:) = {NaN(400, 10)};
    end
    
    for j = 1:2
        sessionData{j}(:,1) = groupData(i).(sprintf('session%d',j)).Bimodal_localization_data{1,1}.subjID;
        sessionData{j}(:,2) = groupData(i).(sprintf('session%d',j)).Bimodal_localization_data{1,5}...
                                  .trialConditions(1,:);
        sessionData{j}(:,3) = centroids(sessionData{j}(:,2)); % A centroids
        sessionData{j}(:,4) = groupData(i).(sprintf('session%d',j)).Bimodal_localization_data{1,5}...
                                  .trialConditions(2,:);
        sessionData{j}(:,5) = centroids(sessionData{j}(:,2)); % V centroids
        sessionData{j}(:,6) = groupData(i).(sprintf('session%d',j)).Bimodal_localization_data{1,5}...
                                  .trialConditions(3,:); % disc
        sessionData{j}(:,7) = groupData(i).(sprintf('session%d',j)).Bimodal_localization_data{1,5}...
                                  .trialConditions(4,:); % corr
        sessionData{j}(:,8) = groupData(i).(sprintf('session%d',j)).Bimodal_localization_data{1,5}...
                                  .AVlocTrialOrder; % modality 1=A; 2=V 
        sessionData{j}(:,9) = groupData(i).(sprintf('session%d',j)).Bimodal_localization_data{1,5}...
                                  .localization; % localization responses
        sessionData{j}(:,10) = groupData(i).(sprintf('session%d',j)).Bimodal_localization_data{1,5}...
                                  .unity; % unity responses
    end
    VE_ujdg_ind{i} = cat(1,sessionData{1},sessionData{2});
end

% group-level
VE_ujdg_group = cat(1,VE_ujdg_ind{1:9});






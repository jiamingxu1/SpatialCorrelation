%% Group-level behavioral analyses for unity judgement and VE

clear all; clc;
subjN = [2,3,4,5,7,8,9,10,11];
subjI = {'JX','HHL','ZGL','ZD','YX','DT','TA','MD','BY'};

% load unimodal data
for i = 1:length(subjN)
    addpath(genpath(['/Users/jiamingxu/Desktop/Github/SpatialCorrelation/',...
        'Experiment_code/2_unimodalLocSeq/Analysis/', subjI{i}]));
end
% initialize
indData1 = struct('uniLoc',[]);
groupData1 = repmat(indData1, length(subjN), 1);
% useful expt info
lenN        = length(subjN);
centroids   = [-24 -14 -4 6 16 26];
lenCent     = length(centroids);
nP          = 40;
% load data
for i = 1:lenN
    groupData1(i).uniLoc = load(['UnimodalLocSeq_sub', num2str(subjN(i)),'.mat']);
end
% organize data into a big matrix
% 1. subjN               : subject ID
% 2. A centroid (actual) : A centroid location to be localized for a given trial (in deg)
% 3. A loc resp          : A centroid localization response (in deg)
% 4. V centroid (actual) : V centroid location to be localized for a given trial (in deg)
% 5. V loc resp          : A centroid localization response (in deg)

uniLocResp_ind = cell(lenN,1); uniLocResp_ind(:) = {NaN(240, 5)};
for i = 1:lenN
    uniLocResp_ind{i}(:,1) = groupData1(i).uniLoc.Unimodal_localization_data{1,1}.subjID(:); % subjID
    uniLocResp_ind{i}(:,2) = groupData1(i).uniLoc.Unimodal_localization_data{1,4}.data(1,:); % actualA
    uniLocResp_ind{i}(:,3) = groupData1(i).uniLoc.Unimodal_localization_data{1,4}.data(2,:); % A loc resp
    uniLocResp_ind{i}(:,4) = groupData1(i).uniLoc.Unimodal_localization_data{1,3}.data(1,:); % actualV
    uniLocResp_ind{i}(:,5) = groupData1(i).uniLoc.Unimodal_localization_data{1,3}.data(3,:); % V loc resp
end
% concatenate ind. subject data to get group-level data
uniLocResp_group = cat(1,uniLocResp_ind{1:9});
% calculate mean for each subject for all 6 centroid locations
meanLocA_uni = NaN(lenN,lenCent); meanLocV_uni = NaN(lenN,lenCent);
for i = 1:lenN
    meanLocA_uni(i,:) = arrayfun(@(idx) mean(uniLocResp_ind{i}(abs(uniLocResp_ind{i}(:,2) -...
                        centroids(idx)) < 1e-3, 3)), 1:length(centroids));
    meanLocV_uni(i,:) = arrayfun(@(idx) mean(uniLocResp_ind{i}(abs(uniLocResp_ind{i}(:,4) -...
                        centroids(idx)) < 1e-3, 5)), 1:length(centroids));
end


%% load bimodal data
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

% useful expt info
sessions    = [1 2];
lenS        = length(sessions);
modality    = {'A','V'};
lenM        = length(modality);
disc_levels = [-20 -10 0 10 20];
lenD        = length(disc_levels);
corr_levels = -1:0.5:1;
lenCorr     = length(corr_levels);
numReps     = 40; %40 for subj 1 and 2; 32 for the rest
nTT         = lenS*lenD*lenCorr*numReps;

% organize data into a big matrix 
% 1. subjN            : subject ID
% 2. A centroid idx   : A centroid idx
% 3. A centroid       : A centroid location 
% 4. V centroid idx   : V centroid idx
% 5. V centroid       : V centroid location 
% 6. disc             : discrepancy between the AV pair (V-A)
% 7. corr             : correlation between the AV pair
% 8. localizeModality : cued modality after stimulus presentation (1: A, 2, V)
% 9. locResp          : localization responses (in deg)
% 10. unityResp       : reported common-cause judgment (1: C=1, 2: C=2)

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
                                  .trialConditions(1,:); % A centroid idx
        sessionData{j}(:,3) = centroids(sessionData{j}(:,2)); % A centroids
        sessionData{j}(:,4) = groupData(i).(sprintf('session%d',j)).Bimodal_localization_data{1,5}...
                                  .trialConditions(2,:); % V centroid idx
        sessionData{j}(:,5) = centroids(sessionData{j}(:,4)); % V centroids
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

% group-level data 
VE_ujdg_group = cat(1,VE_ujdg_ind{1:9});


%% unity judgment analysis 

trialidx = cell(lenD,lenCorr,lenN); unityResp_reshaped = cell(lenD,lenCorr,lenN);
PC1_resp = NaN(lenD,lenCorr,lenN); PC1_respAvg = NaN(lenD,lenCorr);
for i = 1:lenD
    for j = 1:lenCorr
        for m = 1:lenN
            if m == 1||m == 2; numReps = 40; else; numReps = 32; end
            for k = 1:numReps
                indices = find(VE_ujdg_group(:,1) == subjN(m)...
                    & VE_ujdg_group(:,6) == disc_levels(i)...
                    & VE_ujdg_group(:,7) == corr_levels(j));
                trialidx{i,j,m} = indices;
            end
            %subject level ujdg response for each disc x corr 
            for k = 1:numReps
                unityResp = VE_ujdg_group(trialidx{i,j,m},10); 
                unityResp_reshaped{i,j,m} = unityResp;
                PC1_resp(i,j,m) = sum(unityResp_reshaped{i,j,m} == 1)/numReps;
            end
            PC1_respAvg(i,j) = mean(PC1_resp(i,j,PC1_resp(i,j,:) ~= 0));
        end
    end
end


%% plot unity responses as a function of disc and corr
x_bds          = [disc_levels(1) - 2, disc_levels(end) + 2]; 
y_bds          = [-0.05,1.05];
x_ticks_AVdiff = disc_levels; 
y_ticks        = 0:0.25:1;
lw             = 2.5; %lineWidth
fs_lbls        = 20; %font size
fs_lgds        = 15;
cMap_unity     = [0 0.4470 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;...
                  0.4940 0.1840 0.5560;0.4660 0.6740 0.1880];
lgd_corr       = {'r = -1','r = -0.5','r = 0','r = 0.5','r = 1'};

figure(1)
for i = 1:lenCorr
    fig1(i) = plot(disc_levels, PC1_respAvg(:,i), '-o',...
        'MarkerSize',6,'Color',cMap_unity(i,:),...
        'MarkerFaceColor',cMap_unity(i,:),'MarkerEdgeColor',...
        cMap_unity(i,:),'lineWidth',lw); hold on 
end        
   
%add legends 
legend([fig1(1) fig1(2) fig1(3) fig1(4) fig1(5)], lgd_corr,...
    'FontSize',fs_lgds); legend boxoff;
xticks(x_ticks_AVdiff); xlim(x_bds); xlabel('Spatial discrepancy (V - A, deg)'); 
ylabel(sprintf('The probability \n of reporting a common cause')); 
title('P(C=1) as a function of spatial discrepancy and correlation');
yticks(y_ticks);ylim(y_bds);
set(gca,'FontSize',fs_lbls);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.75, 0.60]);
set(gcf,'PaperUnits','centimeters','PaperSize',[50 25]);
% saveas(gcf, ['UnityJdg_btwPrePost_',subjI], 'pdf'); 


%% VE group-level analyses 

% initialize
% A/VlocResp_reshaped: store the localization responses
% 5(disc levels) x 5(corr levels) x 6(centroids) x subjectN x #reps(diff for each condition)
numReps = 40;
AlocResp_reshaped  = cell(lenCent,lenCent,lenCorr,lenN,numReps);
VlocResp_reshaped  = cell(lenCent,lenCent,lenCorr,lenN,numReps);
% meanLocA/V_bi store mean of each disc x corr, centroid, for each subject
meanLocA_bi        = cell(lenD,lenCorr,lenCent,lenN);
meanLocV_bi        = cell(lenD,lenCorr,lenCent,lenN);

% get trial idx for each disc x corr, each centroid location
trialidx2 = cell(lenCent,lenCent,lenCorr,lenN,numReps);
VE_AtrialByTrial = NaN(7600,1); VE_VtrialByTrial = NaN(7600,1);
for i = 1:lenCent %A centroids
    for j = 1:lenCent %V centroids
        for m = 1:lenCorr 
            for l = 1:lenN
                   indices = find(VE_ujdg_group(:,3) == centroids(i)...
                        & VE_ujdg_group(:,5) == centroids(j)...
                        & VE_ujdg_group(:,7) == corr_levels(m)...
                        & VE_ujdg_group(:,1) == subjN(l));
                for k = 1:length(indices)
                    trialidx2{i,j,m,l,k} = indices(k); % get idx
                    % grab localization response (A OR V)
                    if VE_ujdg_group(trialidx2{i,j,m,l,k},8) == 1
                        AlocResp_reshaped{i,j,m,l,k} = VE_ujdg_group(trialidx2{i,j,m,l,k},9);
                        VE_AtrialByTrial(trialidx2{i,j,m,l,k}) = AlocResp_reshaped{i,j,m,l,k} - meanLocA_uni(l,i);
                    else
                        VlocResp_reshaped{i,j,m,l,k} = VE_ujdg_group(trialidx2{i,j,m,l,k},9);
                        VE_VtrialByTrial(trialidx2{i,j,m,l,k}) = VlocResp_reshaped{i,j,m,l,k} - meanLocV_uni(l,j);
                    end  
                end
            end
        end
    end
end

% compute group-level mean for each disc x corr
VE_audAvg = NaN(lenD,lenCorr); VE_visAvg = NaN(lenD,lenCorr);
for i = 1:lenD
    for j = 1:lenCorr
        trialidx3 = find(VE_ujdg_group(:,6) == disc_levels(i)...
                  & VE_ujdg_group(:,7) == corr_levels(j));
        VE_audAvg(i,j) = mean(VE_AtrialByTrial(trialidx3),'omitnan');
        VE_visAvg(i,j) = -(mean(VE_VtrialByTrial(trialidx3),'omitnan'));
    end
end


%% plot auditory VE as a function of disc and corr
x_bds          = [disc_levels(1) - 2, disc_levels(end) + 2]; 
y_bds          = [min(min(VE_audAvg))-5, max(max(VE_audAvg))+5];
x_ticks_AVdiff = disc_levels; 
y_ticks        = -10:2:10; 
lw             = 2.5; %lineWidth
fs_lbls        = 20; %font size
fs_lgds        = 15;
cMap_VE     = [0 0.4470 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;...
                  0.4940 0.1840 0.5560;0.4660 0.6740 0.1880];
lgd_corr       = {'r = -1','r = -0.5','r = 0','r = 0.5','r = 1'};
x = linspace(-26,26,26); y = zeros(size(x));

figure(2)
identity_line = plot(x, x,'k'); hold on
horizontal_line = plot(x, y,'k--'); hold on

for i = 1:lenCorr
    fig2(i) = plot(disc_levels, VE_audAvg(:,i), '-o',...
        'MarkerSize',6,'Color',cMap_VE(i,:),...
        'MarkerFaceColor',cMap_VE(i,:),'MarkerEdgeColor',...
        cMap_VE(i,:),'lineWidth',lw); hold on 
end        
   
%add legends 
legend([fig2(1) fig2(2) fig2(3) fig2(4) fig2(5)], lgd_corr,...
    'FontSize',fs_lgds); legend boxoff;
xticks(x_ticks_AVdiff); xlim(x_bds); xlabel('Spatial discrepancy (V - A, deg)'); 
ylabel(sprintf('Auditory ventriloquism effect')); 
title('Auditory ventrilquism effect as a function of spatial discrepancy and correlation');
yticks(y_ticks);ylim(y_bds);
set(gca,'FontSize',fs_lbls);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.75, 0.60]);
set(gcf,'PaperUnits','centimeters','PaperSize',[50 25]);
%saveas(gcf, 'group_level_ujdg', 'pdf'); 


% plot visual VE as a function of disc and corr
x_bds          = [disc_levels(1) - 2, disc_levels(end) + 2]; 
y_bds          = [min(min(VE_visAvg))-5, max(max(VE_visAvg))+5];
x_ticks_AVdiff = disc_levels; 
y_ticks        = -5:1:5; 
lw             = 2.5; %lineWidth
fs_lbls        = 20; %font size
fs_lgds        = 15;
cMap_VE        = [0 0.4470 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;...
                  0.4940 0.1840 0.5560;0.4660 0.6740 0.1880];
lgd_corr       = {'r = -1','r = -0.5','r = 0','r = 0.5','r = 1'};
x = linspace(-26,26,26); y = zeros(size(x));

figure(3)
identity_line = plot(x, x, 'k'); hold on
horizontal_line = plot(x, y,'k--'); hold on

for i = 1:lenCorr
    fig3(i) = plot(disc_levels, VE_visAvg(:,i), '-o',...
        'MarkerSize',6,'Color',cMap_VE(i,:),...
        'MarkerFaceColor',cMap_VE(i,:),'MarkerEdgeColor',...
        cMap_VE(i,:),'lineWidth',lw); hold on 
end        
   
%add legends 
legend([fig3(1) fig3(2) fig3(3) fig3(4) fig3(5)], lgd_corr,...
    'FontSize',fs_lgds); legend boxoff;
xticks(x_ticks_AVdiff); xlim(x_bds); xlabel('Spatial discrepancy (A - V, deg)'); 
ylabel(sprintf('Visual ventriloquism effect')); 
title('Visual ventrilquism effect as a function of spatial discrepancy and correlation');
yticks(y_ticks);ylim(y_bds);
set(gca,'FontSize',fs_lbls);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.75, 0.60]);
set(gcf,'PaperUnits','centimeters','PaperSize',[50 25]);
%saveas(gcf,'group_level_VE_', 'pdf'); 


%% write into an excel table
VE_ujdg_group_temp = [VE_ujdg_group,VE_AtrialByTrial,VE_VtrialByTrial];
col_keep = [1,6,7,8,9,10,11,12]; VE_ujdg_group_xlsx = VE_ujdg_group_temp(:,col_keep);
varName = {'subjID','disc','corr','locModality','locResp','ujdg','audVE','visVE'};
Table_VE_ujdg = array2table(VE_ujdg_group_xlsx,'VariableNames',varName);
fileName = 'VE_ujdg_trialByTrial_allSubj';
writetable(Table_VE_ujdg,[fileName,'.xlsx'],'Sheet','MyNewSheet',...
    'WriteVariableNames',true);
writetable(Table_VE_ujdg, [fileName, '.txt']);

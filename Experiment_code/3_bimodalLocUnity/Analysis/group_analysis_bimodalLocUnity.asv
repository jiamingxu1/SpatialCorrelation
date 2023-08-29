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
% expt info
lenN        = length(subjN);
centroids   = [-24 -14 -4 6 16 26];
lenCent     = length(centroids);
nP          = 40;
% fetch data
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


% load bimodal data
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
corr_levels = -1:0.5:1;
lenCorr     = length(corr_levels);
numReps     = 40; %40 for subj 1 and 2; 32 for the rest
nTT         = lenS*lenD*lenCorr*numReps;

% organize data into a big matrix 
% 1. subjN            : subject ID
% 2. A centroid idx   : A centroid idx
% 3. A centroid       : A centroid location for a given trial (in deg)
% 4. V centroid idx   : V centroid idx
% 5. V centroid       : V centroid location for a given trial (in deg)
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
colNames = {'subjID','Acentroid_idx','Acentroids','Vcentroid_idx','Vcentroids,...' ...
    'disc','corr','modality','loc_resp','unity'};
VE_ujdg_table = array2table(VE_ujdg_group, 'VariableNames', colNames);


%% unity judgment analysis 

trialidx = cell(lenD,lenCorr,lenN); 
for i = 1:lenD
    for j = 1:lenCorr
        for m = 1:lenN
            if m == 1 || m == 2
                numReps = 40;
            else
                numReps = 32;
            end
            for k = 1:numReps
                indices = find(VE_ujdg_group(:,1) == subjN(m)...
                    & VE_ujdg_group(:,6) == disc_levels(i)...
                    & VE_ujdg_group(:,7) == corr_levels(j));
                trialidx{i,j,m} = indices;
            end
        end
    end
end

unityResp_reshaped = cell(lenD,lenCorr,lenN);
PC1_resp = NaN(lenD,lenCorr,lenN); PC1_respAvg = NaN(lenD,lenCorr);
for i = 1:lenD
    for j = 1:lenCorr
        for m = 1:lenN
            if m == 1 || m == 2
                numReps = 40;
            else
                numReps = 32;
            end
            for k = 1:numReps
                unityResp = VE_ujdg_group(trialidx{i,j,m},10); %subject level ujdg response for each condition 
                unityResp_reshaped{i,j,m} = unityResp;
                PC1_resp(i,j,m) = sum(unityResp_reshaped{i,j,m} == 1)/numReps;
            end   
            PC1_respAvg(i,j) = mean(PC1_resp(i,j,PC1_resp(i,j,:) ~= 0));
        end
    end
end


% plot unity responses as a function of disc and corr
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

% initialize data matrices
% A/VlocResp_reshaped: stores the localization responses
% 5(disc levels) x 5(corr levels) x 6(centroids) x subjectN x #reps(diff for each condition)
numReps = 40;
% get trial idx for each condition, each centroid location
trialidx2 = cell(lenD,lenCorr,lenCent,lenN,numReps);
for i = 1:lenD
    for j = 1:lenCorr
        for m = 1:lenCent
            for l = 1:lenN
                   indices = find(VE_ujdg_group(:,1) == subjN(l)...
                        & VE_ujdg_group(:,6) == disc_levels(i)...
                        & VE_ujdg_group(:,7) == corr_levels(j)...
                        & (VE_ujdg_group(:,3) == centroids(m)...
                         | VE_ujdg_group(:,5) == centroids(m)));
                for k = 1:length(indices)
                % Store the indices in the cell arrays
                   trialidx2{i,j,m,l,k} = indices(k);
                end
            end
        end
    end
end

% grab localization responses for each suject, each condition, each centroid location
AlocResp_reshaped  = cell(lenD,lenCorr,lenCent,lenN,numReps);  
VlocResp_reshaped  = cell(lenD,lenCorr,lenCent,lenN,numReps);
for i = 1:lenD
    for j = 1:lenCorr
        for m = 1:lenCent
            for l = 1:lenN
                if l == 1 || l == 2
                    numReps = 40;
                else
                    numReps = 32;
                end
                for k = 1:numReps
                    if ~isempty(trialidx2{i,j,m,l,k})
                       if VE_ujdg_group(trialidx2{i,j,m,l,k},8) == 1
                            AlocResp_reshaped{i,j,m,l,k} = VE_ujdg_group(trialidx2{i,j,m,l,k},9);
                       else
                            VlocResp_reshaped{i,j,m,l,k} = VE_ujdg_group(trialidx2{i,j,m,l,k},9);                 
                       end  
                    end
                end
            end
        end
    end
end

% calculate the mean for each subject, each condition, each centroid
% location
meanLocA_bi        = cell(lenD,lenCorr,lenCent,lenN);
meanLocV_bi        = cell(lenD,lenCorr,lenCent,lenN);
for i = 1:lenD
    for j = 1:lenCorr
        for m = 1:lenCent
            for l = 1:lenN
                if l == 1 || l == 2
                    numReps = 40;
                else
                    numReps = 32;
                end
                % Initialize arrays to hold non-empty values
                nonEmptyA = []; nonEmptyV = [];
                for k = 1:numReps
                    if ~isempty(AlocResp_reshaped{i, j, m, l, k})
                        nonEmptyA = [nonEmptyA; AlocResp_reshaped{i, j, m, l, k}(:)];
                    end

                    if ~isempty(VlocResp_reshaped{i, j, m, l, k})
                        nonEmptyV = [nonEmptyV; VlocResp_reshaped{i, j, m, l, k}(:)];
                    end
                end
                % Calculate means for AlocResp_reshaped and VlocResp_reshaped
                meanLocA_bi{i, j, m, l} = mean(nonEmptyA, 'omitnan');
                meanLocV_bi{i, j, m, l} = mean(nonEmptyV, 'omitnan');
            end
        end
    end
end

% compute group-level VE
VE_audCentroid_ind = cell(lenD,lenCorr,lenCent,lenN); VE_audCentroid_group = NaN(lenD,lenCorr,lenCent); VE_audAvg = NaN(lenD,lenCorr);
VE_visCentroid_ind = cell(lenD,lenCorr,lenCent,lenN); VE_visCentroid_group = NaN(lenD,lenCorr,lenCent); VE_visAvg = NaN(lenD,lenCorr);
for i = 1:lenD
    for j = 1:lenCorr
        for m = 1:lenCent
            for l = 1:lenN
                % auditory and visual VE for each disc and corr, at each
                % centroid location
                if ~isempty(meanLocA_bi{i,j,m,l}) && ~isempty(meanLocV_bi{i,j,m,l})
                    VE_audCentroid_ind{i,j,m,l} = meanLocA_bi{i,j,m,l} - meanLocA_uni(l,m);
                    VE_visCentroid_ind{i,j,m,l} = meanLocV_bi{i,j,m,l} - meanLocV_uni(l,m); 
                end
            end
            VE_audCentroid_group(i,j,m) = mean(cell2mat(VE_audCentroid_ind(i, j, m, :)), 'omitnan');
            VE_visCentroid_group(i,j,m) = mean(cell2mat(VE_visCentroid_ind(i, j, m, :)), 'omitnan');
        end
        VE_audAvg(i,j) = mean(VE_audCentroid_group(i,j,:),'omitnan');
        VE_visAvg(i,j) = mean(VE_visCentroid_group(i,j,:),'omitnan');
    end
end

%% plot auditory VE as a function of disc and corr
x_bds          = [disc_levels(1) - 2, disc_levels(end) + 2]; 
y_bds          = [min(min(VE_audAvg))-5, max(max(VE_audAvg))+5];
x_ticks_AVdiff = disc_levels; 
y_ticks        = -10:5:10; %ceil(min(min(VE_audAvg))-5):5:ceil(max(max(VE_audAvg))+5);
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
xticks(x_ticks_AVdiff); xlim(x_bds); xlabel('Spatial discrepancy (A - V, deg)'); 
ylabel(sprintf('Auditory ventriloquism effect')); 
title('Auditory ventrilquism effect as a function of spatial discrepancy and correlation');
yticks(y_ticks);ylim(y_bds);
set(gca,'FontSize',fs_lbls);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.75, 0.60]);
set(gcf,'PaperUnits','centimeters','PaperSize',[50 25]);
% saveas(gcf, 'group_level_ujdg', 'pdf'); 



% plot visual VE as a function of disc and corr
x_bds          = [disc_levels(1) - 2, disc_levels(end) + 2]; 
y_bds          = [min(min(VE_visAvg))-5, max(max(VE_visAvg))+5];
x_ticks_AVdiff = disc_levels; 
y_ticks        = -10:5:10; %ceil(min(min(VE_audAvg))-5):5:ceil(max(max(VE_audAvg))+5);
lw             = 2.5; %lineWidth
fs_lbls        = 20; %font size
fs_lgds        = 15;
cMap_VE     = [0 0.4470 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;...
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
xticks(x_ticks_AVdiff); xlim(x_bds); xlabel('Spatial discrepancy (V - A, deg)'); 
ylabel(sprintf('Visual ventriloquism effect')); 
title('Visual ventrilquism effect as a function of spatial discrepancy and correlation');
yticks(y_ticks);ylim(y_bds);
set(gca,'FontSize',fs_lbls);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.75, 0.60]);
set(gcf,'PaperUnits','centimeters','PaperSize',[50 25]);
% saveas(gcf,'group_level_VE_', 'pdf'); 


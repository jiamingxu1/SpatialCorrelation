% Analysis for bimodal localization and unity judgment task

%% select output 
clear all; close all; clc
subjN_dict = [2,3,4,5,6,7,8,9,10,11];
subjI_dict = {'JX','HHL','ZGL','ZD','SX','YX','DT','TA','MD','BY'};

% create popout window
prompt     = {'Subject ID:','Plot unity judgment (1:yes; 0: no):',...
                'Plot auditory VE:', 'Plot visual VE:',...
                'save data', 'export a table for unityJdg', ...
                'export a table for locR:', 'export a table for locR (abs(spatialD)):'};
dlgtitle   = 'Input';
dims       = [1 35];
definput   = {'2','1','1','1','1','0','0','0'};
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

[Acentroid_idx,Vcentroid_idx,disc_temp,corr_temp,locModality_temp,locResp_temp,unityResp_temp]...
                               = deal(NaN(2, 400)); % nTT/2

% load conditions and data files                    
for i = 1:2 % session 1-2
   
    C = load(['BimodalLocSeq_','sub', num2str(subjN),...
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

% load experiment information
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
                        

%% unity judgments (PC=1 as a function of disc and corr) 
% initialize data matrices
% unityMat  : stores common-cause judgments
%            5 (disc levels) x 5 (corr levels) x 20 (trials) x 2 (sessions)
% pC1_resp  : stores the percentage of C = 1 responses for each AV pair
%            5 (disc levels) x 5 (corr levels) 

unityMat    = NaN(lenD, lenCorr, numReps*2);
pC1_resp    = NaN(lenD, lenCorr);

% get trial idx for each condition
trialridx = NaN(lenD,lenCorr,numReps*2);
trialcidx = NaN(lenD,lenCorr,numReps*2);
for i = 1:lenD
    for j = 1:lenCorr
        for k = 1:numReps*2
            [trialridx(i,j,:), trialcidx(i,j,:)] = find(disc == ExpInfo.disc(i) & corr == ExpInfo.corrVals(j));
        end
    end
end

% fetch unity responses from those trials
unityResp_reshaped = NaN(lenD,lenCorr,numReps*2);
for i = 1:lenD
    for j = 1:lenCorr
        for k = 1:numReps*2
            unityResp_reshaped(i,j,k) = unityResp(trialcidx(i,j,k));
        end
        pC1_resp(i,j) = sum(unityResp_reshaped(i,j,:) == 1)/(numReps*2);
    end
end

% plot unity responses as a function of disc and corr
x_bds          = [ExpInfo.disc(1) - 2, ExpInfo.disc(end) + 2]; 
y_bds          = [-0.05,1.05];
x_ticks_AVdiff = ExpInfo.disc; 
y_ticks        = 0:0.25:1;
lw             = 2.5; %lineWidth
fs_lbls        = 20; %font size
fs_lgds        = 15;
cMap_unity     = [0 0.4470 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;...
                  0.4940 0.1840 0.5560;0.4660 0.6740 0.1880];
lgd_corr       = {'r = -1','r = -0.5','r = 0','r = 0.5','r = 1'};
% lgd_pos      = [0.25 0.15 0.05 0.1; 0.45 0.15 0.05 0.1; 0.65 0.15 0.05 0.1;...
%                0.85 0.15 0.05 0.1; 1.05 0.15 0.05 0.1;1.25 0.15 0.05 0.1]; 
% 'Position',lgd_pos(i,:),

if bool_plt(1) == 1
    figure(1)
    for i = 1:lenCorr
%         addBackground(x_bds, y_bds, x_ticks_AVdiff, y_ticks)
        fig1(i) = plot(ExpInfo.disc, pC1_resp(:,i), '-o',...
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
%     saveas(gcf, ['UnityJdg_btwPrePost_',subjI], 'pdf'); 
end


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


%% ventriloquism effect as a function of disc and corr for each centroid location

% initialize data matrices
% A/VlocResp_reshaped: stores the localization responses
% 5(disc levels) x 5(corr levels) x 6(centroids) x #reps(diff for each condition)
AlocResp_reshaped  = cell(lenD,lenCorr,lenCent,numReps);  
VlocResp_reshaped  = cell(lenD,lenCorr,lenCent,numReps);
meanLocA_bi        = cell(lenD,lenCorr,lenCent);
meanLocV_bi        = cell(lenD,lenCorr,lenCent);

% get trial idx for each condition, each centroid location
trialridx2 = cell(lenD,lenCorr,lenCent,numReps);
for i = 1:lenD
    for j = 1:lenCorr
        for m = 1:lenCent
               condition_idx = find(disc == ExpInfo.disc(i) ...
                    & corr == ExpInfo.corrVals(j) & (Acentroid == centroids(m)...
                     | Vcentroid == centroids(m)));
            for k = 1:length(condition_idx)
            % Store the indices in the cell arrays
               trialridx2{i, j, m, k} = condition_idx(k);
            end
        end
    end
end

% grab localization responses for each condition, each centroid location
for i = 1:lenD
    for j = 1:lenCorr
        for m = 1:lenCent
            for k = 1:size(trialridx2,4)
               if locModality(trialridx2{i,j,m,k}) == 1
                    AlocResp_reshaped{i,j,m,k} = locResp(trialridx2{i,j,m,k});
               else
                    VlocResp_reshaped{i,j,m,k} = locResp(trialridx2{i,j,m,k});                   
               end  
            end
            if ~isempty(cell2mat(AlocResp_reshaped(i,j,m,:)))
                meanLocA_bi{i,j,m} = nanmean(cell2mat(AlocResp_reshaped(i,j,m,:)));
            else
                meanLocA_bi{i,j,m} = NaN; 
            end
            if ~isempty(cell2mat(VlocResp_reshaped(i,j,m,:)))
                meanLocV_bi{i,j,m} = nanmean(cell2mat(VlocResp_reshaped(i,j,m,:)));
            else
                meanLocV_bi{i,j,m} = NaN; 
            end
        end
    end
end

% plot localization responses at each centroid location 
meanLocA_centroid = NaN(1,6); meanLocV_centroid = NaN(1,6); 
for m = 1:6
    meanLocA_centroid(m) = mean(nanmean(cell2mat(meanLocA_bi(:,:,m))));
    meanLocV_centroid(m) = mean(nanmean(cell2mat(meanLocV_bi(:,:,m))));
end

% plot auditory localization
x = linspace(-26,26,26);
figure(2)
plot(centroids, meanLocA_centroid, '-o',...
            'MarkerSize',6,...
            'lineWidth',lw); hold on 
identity_line = plot(x, x, 'k--'); 
xticks(centroids); xlim([-26 26]); xlabel('Centroids'); 
    ylabel(sprintf('Auditory localization')); 
    title('Auditory localization in bimodal trials');
    yticks(-40:10:40);ylim([-40 40]);
    set(gca,'FontSize',12);

% plot visual localization 
figure(3)
plot(centroids, meanLocV_centroid, '-o',...
            'MarkerSize',6,...
            'lineWidth',lw); hold on 
identity_line = plot(x, x, 'k--'); 
xticks(centroids); xlim([-26 26]); xlabel('Centroids'); 
    ylabel(sprintf('Visual localization')); 
    title('Visual localization in bimodal trials');
    yticks(-40:10:40);ylim([-40 40]);
    set(gca,'FontSize',12);



%% compute auditory and visual ventriloquism effects 
VE_audCentroid = cell(lenD,lenCorr,lenCent); VE_audAvg = NaN(lenD,lenCorr);
VE_visCentroid = cell(lenD,lenCorr,lenCent); VE_visAvg = NaN(lenD,lenCorr);
for i = 1:lenD
    for j = 1:lenCorr
        for m = 1:lenCent
            % auditory and visual VE for each disc and corr, at each
            % centroid location
            VE_audCentroid{i,j,m} = meanLocA_bi{i,j,m} - meanLocA_uni(m);
            VE_visCentroid{i,j,m} = meanLocV_bi{i,j,m} - meanLocV_uni(m); 
        end
        % auditory and visual VE for each disc and corr, averaged across 6 centroid locations
        VE_audAvg(i,j) = nanmean(cell2mat(VE_audCentroid(i,j,:)));
        VE_visAvg(i,j) = nanmean(cell2mat(VE_visCentroid(i,j,:)));
    end
end

% plot auditory VE as a function of disc and corr
x_bds          = [ExpInfo.disc(1) - 2, ExpInfo.disc(end) + 2]; 
y_bds          = [min(min(VE_audAvg))-5, max(max(VE_audAvg))+5];
x_ticks_AVdiff = ExpInfo.disc; 
y_ticks        = ceil(min(min(VE_audAvg))-5):5:ceil(max(max(VE_audAvg))+5);
lw             = 2.5; %lineWidth
fs_lbls        = 20; %font size
fs_lgds        = 15;
cMap_VE     = [0 0.4470 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;...
                  0.4940 0.1840 0.5560;0.4660 0.6740 0.1880];
lgd_corr       = {'r = -1','r = -0.5','r = 0','r = 0.5','r = 1'};
% lgd_pos      = [0.25 0.15 0.05 0.1; 0.45 0.15 0.05 0.1; 0.65 0.15 0.05 0.1;...
%                0.85 0.15 0.05 0.1; 1.05 0.15 0.05 0.1;1.25 0.15 0.05 0.1]; 
% 'Position',lgd_pos(i,:),


% VE_audAvg = cell2mat(VE_audCentroid(:,:,4)); VE for each centroid
if bool_plt(2) == 1
    figure(4)
    for i = 1:lenCorr
%         addBackground(x_bds, y_bds, x_ticks_AVdiff, y_ticks)
        fig2(i) = plot(ExpInfo.disc, VE_audAvg(:,i), '-o',...
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
%     saveas(gcf, ['UnityJdg_btwPrePost_',subjI], 'pdf'); 
end


% plot visual VE as a function of disc and corr
x_bds          = [ExpInfo.disc(1) - 2, ExpInfo.disc(end) + 2]; 
y_bds          = [min(min(VE_visAvg))-5, max(max(VE_visAvg))+5];
x_ticks_AVdiff = ExpInfo.disc; 
y_ticks        = ceil(min(min(VE_visAvg))-5):5:ceil(max(max(VE_visAvg))+5);
lw             = 2.5; %lineWidth
fs_lbls        = 20; %font size
fs_lgds        = 15;
cMap_VE     = [0 0.4470 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;...
                  0.4940 0.1840 0.5560;0.4660 0.6740 0.1880];
lgd_corr       = {'r = -1','r = -0.5','r = 0','r = 0.5','r = 1'};
% lgd_pos      = [0.25 0.15 0.05 0.1; 0.45 0.15 0.05 0.1; 0.65 0.15 0.05 0.1;...
%                0.85 0.15 0.05 0.1; 1.05 0.15 0.05 0.1;1.25 0.15 0.05 0.1]; 
% 'Position',lgd_pos(i,:),

if bool_plt(3) == 1
    figure(5)
    for i = 1:lenCorr
%         addBackground(x_bds, y_bds, x_ticks_AVdiff, y_ticks)
        fig3(i) = plot(ExpInfo.disc, VE_visAvg(:,i), '-o',...
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
%     saveas(gcf, ['UnityJdg_btwPrePost_',subjI], 'pdf'); 
end




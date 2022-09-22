% This script plots histograms for the unimodal localization responses
clear all; close all; clc; rng(1);

%% load and organize data
subjN    = 7;
subjI    = 'JH';
addpath(genpath(['/Users/hff/Desktop/NYU/Project5/Experiment code/',...
    'Unimodal localization task/Pilot/',subjI]));
C        = load(['Unimodal_localization_sub', num2str(subjN), '.mat'],...
            'Unimodal_localization_data');
Adata    = C.Unimodal_localization_data{end}.data;
Vdata    = C.Unimodal_localization_data{end-1}.data;
Aloc_deg = C.Unimodal_localization_data{end}.Distance; 
Vloc_deg = C.Unimodal_localization_data{end-1}.initialDistance; 

numBtst            = 1e3;
meanLocResp_A      = NaN(1, length(Aloc_deg));
meanLocResp_V      = NaN(1, length(Vloc_deg));
numTrials_A        = size(Adata,2)/length(Aloc_deg);
numTrials_V        = size(Vdata,2)/length(Vloc_deg);
meanLocResp_A_btst = NaN(numBtst, length(Aloc_deg));
meanLocResp_V_btst = NaN(numBtst, length(Vloc_deg));
meanLocResp_A_95CI = NaN(2, length(Aloc_deg));
meanLocResp_V_95CI = NaN(2, length(Vloc_deg));

for i = 1:length(Aloc_deg)
    indices           = find(abs(Adata(1,:) - Aloc_deg(i)) < 1e-3);
    meanLocResp_A(i)  = mean(Adata(2, indices));
    for j = 1:numBtst
        indices_btst  = indices(randi([1 numTrials_A],[1 numTrials_A]));
        AlocResp_btst = Adata(2,indices_btst);
        meanLocResp_A_btst(i,j) = mean(AlocResp_btst);
    end
    meanLocResp_A_sort = sort(meanLocResp_A_btst(i,:));
    meanLocResp_A_95CI(:,i) = meanLocResp_A_sort([floor(0.025*numBtst),...
        ceil(0.975*numBtst)]);
end

for i = 1:length(Vloc_deg)
    indices           = find(abs(Vdata(1,:) - Vloc_deg(i)) < 1e-3);
    meanLocResp_V(i)  = mean(Vdata(3, indices));
    for j = 1:numBtst
        indices_btst  = indices(randi([1 numTrials_V],[1 numTrials_V]));
        VlocResp_btst = Vdata(3,indices_btst);
        meanLocResp_V_btst(i,j) = mean(VlocResp_btst);
    end
    meanLocResp_V_sort = sort(meanLocResp_V_btst(i,:));
    meanLocResp_V_95CI(:,i) = meanLocResp_V_sort([floor(0.025*numBtst),...
        ceil(0.975*numBtst)]);
end

%% plot the figure
cMAP_V   = [255,165,0;207,183,0;147,196,0;50,205,50]./255;
cMAP_A   = [255,165,0;50,205,50]./255;
x_max    = max(abs(Adata(2,:))); x_bds = [-x_max-5, x_max + 5];
y_bds    = [0,25]; x_ticks = [x_bds(1), Vloc_deg, x_bds(end)];
y_ticks  = 0:10:20;

figure
subplot(1,2,1)
addBackground(x_bds, y_bds, x_ticks, y_ticks)
for i = 1:length(Aloc_deg)
    idx = abs(Adata(1,:) - Aloc_deg(i)) < 1e-3;
    histogram(Adata(2,idx), -x_max:1:x_max,'FaceColor',cMAP_A(i,:),...
        'FaceAlpha', 0.3, 'EdgeColor',cMAP_A(i,:)); hold on
    if i == 1
        plot([Vloc_deg(i), Vloc_deg(i)], y_bds, 'Color',cMAP_A(i,:),...
            'lineWidth', 2, 'lineStyle', '-'); 
    else
        plot([Vloc_deg(end), Vloc_deg(end)], y_bds, 'Color', cMAP_A(i,:),...
            'lineWidth', 2, 'lineStyle', '-'); 
    end
    plot([meanLocResp_A(i), meanLocResp_A(i)], [0, y_bds(end)], 'Color',...
        cMAP_A(i,:), 'lineWidth', 2, 'lineStyle', '--'); 
    text(x_bds(1), y_bds(end)-1, subjI, 'fontSize', 12); 
end
hold off; box off; xticks(Vloc_deg); xlim(x_bds); yticks(y_ticks);
xlabel('Auditory localization (dva)');
ylim(y_bds); ylabel('Counts'); set(gca,'FontSize',15);

subplot(1,2,2)
addBackground(x_bds, y_bds, x_ticks, y_ticks)
for i = 1:length(Vloc_deg)
    idx = abs(Vdata(1,:) - Vloc_deg(i)) < 1e-1;
    histogram(Vdata(3,idx), -x_max:1:x_max, 'FaceColor',cMAP_V(i,:),...
        'FaceAlpha',0.3, 'EdgeColor', cMAP_V(i,:)); hold on
    plot([Vloc_deg(i), Vloc_deg(i)], y_bds, 'Color', cMAP_V(i,:),...
        'lineWidth', 2, 'lineStyle', '-'); hold on;
    plot([meanLocResp_V(i), meanLocResp_V(i)], y_bds, 'Color', cMAP_V(i,:),...
        'lineWidth', 2, 'lineStyle', '--'); hold on;
end
hold off; box off; xticks(Vloc_deg); xlim(x_bds); yticks(y_ticks);
xlabel('Visual localization (dva)'); 
ylim(y_bds); ylabel('Counts'); set(gca,'FontSize',15);

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.7, 0.3]);
set(gcf,'PaperUnits','centimeters','PaperSize',[30 8]);
saveas(gcf, ['UnimodalLocResps_S', num2str(subjN)], 'pdf'); 

%% save the data
data_summary = {[subjN, subjI], [numTrials_A, numTrials_V, numBtst],...
    meanLocResp_A, meanLocResp_V, meanLocResp_A_btst, meanLocResp_V_btst,...
    meanLocResp_A_95CI, meanLocResp_V_95CI};
save(['UnimodalLocalization_dataSummary_S', num2str(subjN)],'data_summary');




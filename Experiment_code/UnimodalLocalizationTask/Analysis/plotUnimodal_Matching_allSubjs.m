%This script aims to compare the mean localization responses collected from
%the unimodal spatial localization task with the perceptually matched
%auditory locations measured from the bimodal spatial discrimination task
clear all; close all; clc; rng(1)
addpath(genpath(['/Users/hff/Desktop/NYU/Project5/Experiment code/',...
    'Unimodal localization task/Pilot/']));
addpath(genpath(['/Users/hff/Desktop/NYU/Project5/Experiment code/Matching/Pilot/']));

%% load data files
subjNs        = 1:7;
subjIs        = {'FH','JX', 'ZL','ZY', 'AD','MD','JH'};
lenS          = length(subjNs);
Vloc          = [-12, 12];
[meanLocResp_A, PSE] = deal(NaN(lenS, length(Vloc)));
[meanLocResp_A_95CI, PSE_95CI] = deal(NaN(lenS, 2, length(Vloc)));

for i = 1:lenS
    B = load(['UnimodalLocalization_dataSummary_S', num2str(subjNs(i)),...
        '.mat'], 'data_summary');
    meanLocResp_A(i,:)        = B.data_summary{3};
    meanLocResp_A_95CI(i,:,:) = B.data_summary{end-1};
    
    addpath(genpath(['/Users/hff/Desktop/NYU/Project5/Experiment code/',...
                'Matching task/Pilot/',subjIs{i}]));
    C        = load(['AV_alignment_sub', num2str(subjNs(i)), '_dataSummary.mat'],...
                'AV_alignment_data');
    PSE(i,:) = C.AV_alignment_data{2}.estimatedP([2,4]);
    PSE_95CI(i,:,:) = [C.AV_alignment_data{2}.PSE_lb; C.AV_alignment_data{2}.PSE_ub];
end

%% plot
x_bds  = Vloc + [-12, 12];
y_bds  = x_bds;
cMAP1  = [255,165,0;50,205,50]./255;
mstyle = {'o','s','d','>','<','^','v'};

figure
plot(x_bds, y_bds, 'k--'); hold on
for i = 1:lenS
    for j = 1:length(Vloc)
        if i == 2; alpha = 0; else; alpha = 0.4; end
        scatter(PSE(i,j), meanLocResp_A(i,j), 180, mstyle{i},...
            'MarkerFaceColor', cMAP1(j,:), 'MarkerEdgeColor', cMAP1(j,:),...
            'MarkerFaceAlpha', alpha, 'lineWidth',1); 
        errorbar(PSE(i,j), meanLocResp_A(i,j), meanLocResp_A(i,j) -...
            meanLocResp_A_95CI(i,1,j), meanLocResp_A_95CI(i,2,j) - ...
            meanLocResp_A(i,j), PSE(i,j) - PSE_95CI(i,1,j),...
            PSE_95CI(i,2,j) - PSE(i,j), 'Color', cMAP1(j,:), 'lineWidth',1); hold on
    end
end
xticks(Vloc); xlim(x_bds);  yticks(sort([Vloc,0])); ylim(y_bds); 
xlabel(sprintf(['Point of subjective equality (dva)\n (Bimodal spatial-',...
    'discrimination task)']));
ylabel(sprintf(['Mean auditory localization response (dva)\n (Unimodal ',...
    'spatial-localization task)']));
axis square; box off; grid on; set(gca,'FontSize',15);
set(gcf,'PaperUnits','centimeters','PaperSize',[18 18]);
saveas(gcf, 'Comparision_MatchedAloc_allSubjs', 'pdf');








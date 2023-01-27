%% Unimodal A/V sequence localization
% Subjects localize the centroid location of either an auditory or a visual 
% sequence
clear; close all; clc; rng('shuffle');

%% Enter participant number & specify display
display = 2; % 1:testing room; 2:my laptop

ExpInfo.subjID = [];
while isempty(ExpInfo.subjID) == 1
    try ExpInfo.subjID = input('Please enter participant ID#: ') ; %'s'
    catch
    end
end

out1FileName   = ['UniJNDseq_sub',num2str(ExpInfo.subjID)];

%% Set up variables 
ExpInfo = setup_param(display); 
ScreenInfo = setup_screen(display);
kb.escKey = KbName('ESCAPE');

%% Visual localization

ExpInfo.nWindow = 10;
ExpInfo.total = 16;
ExpInfo.nEvents = 5;
ExpInfo.nRep = 100000;
rmse = zeros(nRep,1);

for i = 1:nRep
    
   windowstart1 = randi(ExpInfo.nWindow);
   windowstart2 = randi(ExpInfo.nWindow);
   train1 = windowstart1+randperm(10,5);
   train2 = windowstart2+randperm(10,5);
   rmse(i) = sqrt(mean((train1-train2).^2));
    
end

histogram(rmse)


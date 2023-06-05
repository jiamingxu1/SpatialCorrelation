%This script tests subjects' accuracy and precision in localizing the centroids
% of visual and auditory trains stimuli. The visual stimulus is a train of
% 5 gaussian blobs appearing in 5 different locations. The auditory
% stimulus is a train of 5 beeps appearing in 5 different locations. The
% task is to localize the centroid of each train (V/A interleaved). 

%% Enter subject's name
clear all; close all; clc; rng('shuffle');
addpath(genpath('/e/3.3/p3/hong/Desktop/Project5/Psychtoolbox'));

ExpInfo.subjID = [];
while isempty(ExpInfo.subjID) == 1
    try ExpInfo.subjID = input('Please enter participant ID#: ') ; %'s'
    catch
    end
end

%% Screen Setup 
Screen('Preference', 'VisualDebugLevel', 1);
Screen('Preference', 'SkipSyncTests', 1);
% testing----------------------------------------------------
screens = Screen('Screens');
screenNumber = max(screens);
black = BlackIndex(screenNumber);
opacity = 0.7;
PsychDebugWindowConfiguration([], opacity)
[windowPtr, rect] = PsychImaging('OpenWindow', screenNumber, black);
% ------------------------------------------------------------
% [windowPtr,rect] = Screen('OpenWindow', 0, [1,1,1]);
% [windowPtr,rect] = Screen('OpenWindow', 0, [0,0,0],[100 100 1000 480]); % for testing
[ScreenInfo.xaxis, ScreenInfo.yaxis] = Screen('WindowSize',windowPtr);
Screen('TextSize', windowPtr, 35) ;   
Screen('TextFont',windowPtr,'Times');
Screen('TextStyle',windowPtr,1); 

[center(1), center(2)]     = RectCenter(rect);
ScreenInfo.xmid            = center(1); % horizontal center
ScreenInfo.ymid            = center(2); % vertical center
ScreenInfo.backgroundColor = 105;
ScreenInfo.numPixels_perCM = 6.2;
ScreenInfo.liftingYaxis    = 270; 
ifi = Screen('GetFlipInterval', windowPtr);

%fixation locations
ScreenInfo.x1_lb = ScreenInfo.xmid-7; ScreenInfo.x2_lb = ScreenInfo.xmid-1;
ScreenInfo.x1_ub = ScreenInfo.xmid+7; ScreenInfo.x2_ub = ScreenInfo.xmid+1;
ScreenInfo.y1_lb = ScreenInfo.yaxis-ScreenInfo.liftingYaxis-1;
ScreenInfo.y1_ub = ScreenInfo.yaxis-ScreenInfo.liftingYaxis+1;
ScreenInfo.y2_lb = ScreenInfo.yaxis-ScreenInfo.liftingYaxis-7;
ScreenInfo.y2_ub = ScreenInfo.yaxis-ScreenInfo.liftingYaxis+7;

%% Initialise serial object
Arduino = serial('/dev/cu.usbmodemFD131','BaudRate',115200);  
% open for usage
fopen(Arduino);

%% Create A/V sequences
nEvents = 5;
allSeqs = perms(1:nEvents);
nSeq = size(allSeqs,1);

% AV corr matrix
Corr = NaN(nSeq, nSeq);
for ii = 1:nSeq
    for jj = 1:nSeq
        Corr(ii,jj) = corr(allSeqs(ii,:)',allSeqs(jj,:)');
    end
end
   
% construct two arrays with A,V sequences with fixed corr
CorrVal = -1:0.5:1;
nCorr = length(CorrVal); 
nCorrRep = 120; % number of sequences for each correlation
CorrSortedA = cell(nCorrRep,nCorr); %120*5
CorrSortedV = cell(nCorrRep,nCorr);
idxA = NaN(nCorrRep,nCorr); %120*5
idxV = NaN(nCorrRep,nCorr);
for i = 1:nCorr
    [idxA_temp,idxV_temp] = find(Corr > CorrVal(i)-1e-5 &...
        Corr < CorrVal(i)+1e-5); 
    idx_subset = randsample(length(idxA_temp),nCorrRep);
    idxA(:,i) = idxA_temp(idx_subset);
    idxV(:,i) = idxV_temp(idx_subset); 
    % idxA,V correspond to the row numbers in allSeqs. Next, fetch the sequences 
    % from allSeqs and put them into CorrSortedA and CorrSortedV
    for j = 1:nCorrRep
        CorrSortedA{j,i} = allSeqs(idxA(j,i),1:end);
        CorrSortedV{j,i} = allSeqs(idxV(j,i),1:end);
    end
end

% reshape 
% These are the A/V sequences we present in this experiment. Cols are
% centroids of the sequences, rows are the sequences
% p.s.The same sequences are also used for the main expt where we manipulate corr
Atrain_temp         = reshape(CorrSortedA, [], 1); %600*1
Vtrain_temp         = reshape(CorrSortedV, [], 1); %600*1
disc                = (4:5:29)-3; %discrepancies
ExpInfo.centroids   = [4,9,14,19,24,29];
ExpInfo.Atrain      = repmat(Atrain_temp,[1,6]); 
ExpInfo.Vtrain      = repmat(Vtrain_temp,[1,6]);
for i = 1:6
    for j = 1:600
        ExpInfo.Atrain{j,i} = ExpInfo.Atrain{j,i} + disc(i);
        ExpInfo.Vtrain{j,i} = ExpInfo.Vtrain{j,i} + disc(i);
    end
end
%Columns contain A/V trains centered at [1 6 11 16 21 26], respectively
%Rows contain 600 different sequences with the same centroid (randomly draw 
%from these sequences during the experiment)

%% Open speakers
PsychDefaultSetup(2);
InitializePsychSound
devices = PsychPortAudio('GetDevices');
our_device = devices(3).DeviceIndex;


%% Make auditory stimuli (GWN)
AudInfo.fs                  = 44100;
audioSamples                = linspace(1,AudInfo.fs,AudInfo.fs);
standardFrequency_gwn       = 10;
AudInfo.stimDura            = 0.1; 
AudInfo.tf                  = 400; 
AudInfo.intensity           = 0.65;
AudInfo.waitTime            = 0.5;
duration_gwn                = length(audioSamples)*AudInfo.stimDura;
timeline_gwn                = linspace(1,duration_gwn,duration_gwn);
sineWindow_gwn              = sin(standardFrequency_gwn/2*2*pi*timeline_gwn/AudInfo.fs); 
carrierSound_gwn            = randn(1, max(timeline_gwn));
AudInfo.intensity_GWN       = 15;
AudInfo.GaussianWhiteNoise  = [AudInfo.intensity_GWN.*sineWindow_gwn.*carrierSound_gwn;...
                                 AudInfo.intensity_GWN.*sineWindow_gwn.*carrierSound_gwn]; 
AudInfo.inBetweenGWN        = AudInfo.intensity*AudInfo.GaussianWhiteNoise; 
pahandle                    = PsychPortAudio('Open', our_device, [], [], [], 2);%open device

%% Make visual stimuli (gaussian blob)
VSinfo.scaling                       = 0.4; % a ratio between 0 to 1 to be multipled by 255
pblack                               = 1/8; % set contrast to 1*1/8 for the "black" background, so it's not too dark and the projector doesn't complain
VSinfo.numFrames                     = 6;
VSinfo.duration                      = VSinfo.numFrames * ifi;%s
VSinfo.width                         = 201; %(pixel) Increasing this value will make the cloud more blurry (arbituary value)
VSinfo.boxSize                       = 101; %This is the box size for each cloud (arbituary value)
% set the parameters for the visual stimuli
VSinfo.blackBackground               = pblack * ones(ScreenInfo.xaxis,ScreenInfo.yaxis);
VSinfo.transCanvas                   = zeros(ScreenInfo.xaxis,ScreenInfo.yaxis);
x                                    = 1:1:VSinfo.boxSize; y = x;
VSinfo.x                             = x; VSinfo.y = y;
[X,Y]                                = meshgrid(x,y);
cloud_temp                           = mvnpdf([X(:) Y(:)],[median(x) median(y)],...
                                       [VSinfo.width 0; 0 VSinfo.width]);
pscale                               = (1-pblack)/max(cloud_temp); % the max contrast of the blob adds the background contrast should <= 1
cloud_temp                           = cloud_temp .* pscale;
VSinfo.Cloud                         = VSinfo.scaling.*reshape(cloud_temp,length(x),length(y));
VSinfo.blk_texture                   = Screen('MakeTexture', windowPtr, VSinfo.blackBackground,[],[],[],2);

%% Specify some experiment information
ExpInfo.sittingDistance              = 113.0;
ExpInfo.LRmostSpeakers2center        = 65.5;
ExpInfo.LRmostVisualAngle            = (180/pi) * atan(ExpInfo.LRmostSpeakers2center / ...
                                      ExpInfo.sittingDistance);
ExpInfo.stimLocs                     = linspace(-30,30,31); %in deg
ExpInfo.numLocs                      = length(ExpInfo.stimLocs);
ExpInfo.numCentroids                 = 6;
ExpInfo.numTrialsPerLoc              = 2; %2 for practice, 60 for the real experiment
AudInfo.numTotalTrialsA              = ExpInfo.numTrialsPerLoc * ExpInfo.numCentroids;
VSinfo.numTotalTrialsV               = ExpInfo.numTrialsPerLoc * ExpInfo.numCentroids;
                                  
% the order of presenting V/A (if 1: A; %if 2: V)
ExpInfo.order_VSnAS     = [];
for i = 1:AudInfo.numTotalTrialsA
    ExpInfo.order_VSnAS = [ExpInfo.order_VSnAS, randperm(2,2)]; 
end

% shuffle A/V centroid locations
rand_indicesA = [];
for i = 1:ExpInfo.numTrialsPerLoc; rand_indicesA = [rand_indicesA, randperm(6)]; end
rand_indicesV = [];
for i = 1:ExpInfo.numTrialsPerLoc; rand_indicesV = [rand_indicesV, randperm(6)]; end

ExpInfo.trialConditions = NaN(2,AudInfo.numTotalTrialsA+VSinfo.numTotalTrialsV);
ExpInfo.trialConditions(1,ExpInfo.order_VSnAS==1) = ExpInfo.centroids(rand_indicesA); 
ExpInfo.trialConditions(1,ExpInfo.order_VSnAS==2) = ExpInfo.centroids(rand_indicesV); 
ExpInfo.trialConditions(2,ExpInfo.order_VSnAS==1) = rand_indicesA;
ExpInfo.trialConditions(2,ExpInfo.order_VSnAS==2) = rand_indicesV;


% define blocks and break trials
ExpInfo.numBlocks         = 4;
blocks                    = linspace(0,AudInfo.numTotalTrialsA+VSinfo.numTotalTrialsV,...
                            ExpInfo.numBlocks+1); 
% split all the trials into 4 blocks
ExpInfo.breakTrials       = floor(blocks(2:(end-1)));
ExpInfo.numTrialsPerBlock = ExpInfo.breakTrials(1);

%% Initialize data matrices
% Auditory data
%data matrix (double)
%1st row: centroid (in deg)
%2nd row: responses (in deg)
%3rd row: response time
AudInfo.data      = zeros(3,AudInfo.numTotalTrialsA);
AudInfo.data(1,:) = ExpInfo.trialConditions(ExpInfo.order_VSnAS==1); %in deg
%corresponding sequences drawn from ExpInfo.Atrain (cell) -> used for
%recency effect analysis
AudInfo.randSampleAtrain = cell(1,AudInfo.numTotalTrialsA);

% Visual data
%data matrix (double)
%1st row: target centroid (in deg)
%2nd row: target centroid (in cm)
%3rd row: response (in deg)
%4th row: response time
VSinfo.data             = zeros(4,VSinfo.numTotalTrialsV);
VSinfo.data(1,:)        = ExpInfo.trialConditions(ExpInfo.order_VSnAS==2); %in deg
VSinfo.data(2,:)        = tan(deg2rad(VSinfo.data(1,:))).*ExpInfo.sittingDistance;
%Corresponding sequences drawn from ExpInfo.Atrain (cell) -> used for
%recency effect analysis
VSinfo.randSampleVtrain = cell(1, VSinfo.numTotalTrialsV);

%% Run the experiment by calling the functions PresentAuditoryTrain and PresentVisualTrain
%start the experiment
DrawFormattedText(windowPtr, 'Press any button to start the unimodal localization task.',...
    'center',ScreenInfo.yaxis-ScreenInfo.liftingYaxis,[255 255 255]);
Screen('Flip',windowPtr);
KbWait(-3); WaitSecs(1);
Screen('Flip',windowPtr);

for i = 1:(AudInfo.numTotalTrialsA+VSinfo.numTotalTrialsV) 
    colidx = ExpInfo.trialConditions(2,i);
    if ExpInfo.order_VSnAS(i) == 1 %auditory trial
        jj = sum(ExpInfo.order_VSnAS(1:i)==1);
        %randomly sample one sequence from the corresponding col of ExpInfo.Atrain
        AudInfo.randSampleAtrain(jj) = randsample(ExpInfo.Atrain(:,colidx),1); 
        [AudInfo.data(2,jj), AudInfo.data(3,jj)] = PresentAuditoryTrain(i,jj,...
            ExpInfo,ScreenInfo,AudInfo,Arduino,pahandle,windowPtr);
    
    else %visual trial
        ii = sum(ExpInfo.order_VSnAS(1:i)==2);
        %randomly sample one sequence from the corresponding col of ExpInfo.Vtrain
        VSinfo.randSampleVtrain(ii) = randsample(ExpInfo.Vtrain(:,colidx),1); 
        [VSinfo.data(3,ii),VSinfo.data(4,ii)] = PresentVisualTrain(i,...
            ii,ExpInfo,ScreenInfo,VSinfo,windowPtr);
    end
    
    %add breaks     
    if ismember(i,ExpInfo.breakTrials)
        DrawFormattedText(windowPtr, 'You''ve finished one block. Please take a break.',...
            'center',ScreenInfo.yaxis-ScreenInfo.liftingYaxis-30,...
            [255 255 255]);
        DrawFormattedText(windowPtr, 'Press any button to resume the experiment.',...
            'center',ScreenInfo.yaxis-ScreenInfo.liftingYaxis,...
            [255 255 255]);
        Screen('Flip',windowPtr); KbWait(-3); WaitSecs(1);
        Screen('Flip',windowPtr); WaitSecs(0.5);
    end  
end

%% Delete Arduino
fclose(Arduino);
delete(Arduino)
ShowCursor;

%% Save data and end the experiment
Unimodal_localization_data = {ExpInfo,ScreenInfo,VSinfo,AudInfo};
save(out1FileName,'Unimodal_localization_data');
Screen('CloseAll');

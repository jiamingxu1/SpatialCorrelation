% This is the main experiment. We present A and V trains of 5 simultaneously,
% with fixed, repetitive timing. We the spatial locations of A and V
% within a spatial window of 5, such that the corr0 between AV trains range
% from [-1,1]. The task is first localize the centroid of A or V, and then
% report unity judgment. 


%% Enter subject's name, setup screen 
clear all; close all; clc; rng('shuffle');

addpath(genpath('/e/3.3/p3/hong/Desktop/Project5/Psychtoolbox'));
HideCursor;

ExpInfo.subjID = [];

while isempty(ExpInfo.subjID) == 1
    try ExpInfo.subjID = input('Please enter participant ID#: ') ; %'s'
    catch
        
    end
end

%enter session number
ExpInfo.session = [];
while isempty(ExpInfo.session) == 1
    try ExpInfo.session = input('Please enter the session#: ') ; %'s'
        
        
    catch
    end
end


%load the AV sequences with fixed correlations 
addpath(genpath('/e/3.3/p3/hong/Desktop/GitHub/SpatialCorrelation/Experiment_code/2_unimodalLocSeq'));
D = load('AVseqsFixedCorrs.mat');
ExpInfo.Atrain      = D.AVseqsFixedCorrs{1,1};
ExpInfo.Vtrain      = D.AVseqsFixedCorrs{1,2};

ExpInfo.orderedCorr = D.AVseqsFixedCorrs{1,3};
out1FileName        = ['BimodalLocSeq_sub', num2str(ExpInfo.subjID),...
                       '_session', num2str(ExpInfo.session)];

%% Screen Setup 
Screen('Preference', 'VisualDebugLevel', 1);
Screen('Preference', 'SkipSyncTests', 1);
% testing----------------------------------------------------
screens = Screen('Screens');
ScreenInfo.screenNumber = max(screens);
black = BlackIndex(ScreenInfo.screenNumber);
opacity = 1;
PsychDebugWindowConfiguration([], opacity)
[windowPtr, rect] = PsychImaging('OpenWindow', ScreenInfo.screenNumber, black);
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
ScreenInfo.numPixels_perCM = 6.2;
ScreenInfo.liftingYaxis    = 270; 
ScreenInfo.cursorColorA    = [0,0,255]; 
ScreenInfo.cursorColorV    = [255,255,0]; %A: blue, V:yellow
ScreenInfo.dispModalityA   = 'A';
ScreenInfo.dispModalityV   = 'V';
ScreenInfo.x_box_unity     = [-95, -32; 35, 98];
ScreenInfo.y_box_unity     = [-10, 22];

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
VSinfo.blackBackground               = pblack * ones(ScreenInfo.xaxis,ScreenInfo.yaxis) * 255;
VSinfo.transCanvas                   = zeros(ScreenInfo.xaxis,ScreenInfo.yaxis);
x                                    = 1:1:VSinfo.boxSize; y = x;
VSinfo.x                             = x; VSinfo.y = y;
[X,Y]                                = meshgrid(x,y);
cloud_temp                           = mvnpdf([X(:) Y(:)],[median(x) median(y)],...
                                       [VSinfo.width 0; 0 VSinfo.width]);
pscale                               = (1-pblack)/max(cloud_temp); % th0e max contrast of the blob adds the background contrast should <= 1
cloud_temp                           = cloud_temp .* pscale;
VSinfo.Cloud                         = VSinfo.scaling.*reshape(cloud_temp,length(x),length(y))*255;
VSinfo.blk_texture                   = Screen('MakeTexture', windowPtr, VSinfo.blackBackground,[],[],[],2);
    
%% Specify some experiment information
ExpInfo.sittingDistance              = 113.0;
ExpInfo.LRmostSpeakers2center        = 65.5;
ExpInfo.LRmostVisualAngle            = (180/pi) * atan(ExpInfo.LRmostSpeakers2center / ...
                                      ExpInfo.sittingDistance);
ExpInfo.stimLocs                     = linspace(-30,30,31); %in deg
ExpInfo.numLocs                      = length(ExpInfo.stimLocs);
ExpInfo.centroids                    = ExpInfo.stimLocs([4,9,14,19,24,29]);
ExpInfo.numCentroids                 = length(ExpInfo.centroids);
ExpInfo.corrVals                     = -1:0.5:1;
ExpInfo.numCorr                      = length(ExpInfo.corrVals);
ExpInfo.disc                         = [-20 -10 0 10 20];
ExpInfo.numDisc                      = length(ExpInfo.disc);
ExpInfo.numReps                      = 16; %1 for practice, 16 for the real experiment(16*2 sessions = 32 reps in total) 
ExpInfo.AVpairs_allComb              = combvec(1:ExpInfo.numCorr, 1:ExpInfo.numDisc);
% 2*25, 1st row = 5 disc levels, 2nd row = 5 correlations
ExpInfo.numAVpairs                   = size(ExpInfo.AVpairs_allComb, 2);
ExpInfo.numTotalTrials               = ExpInfo.numReps * ExpInfo.numAVpairs; 

% For each discrepancy level, shuffle A/V centroids 
% A: [-24 -14 -4 6 16 26]
% V: [-24 -14 -4 6 16 26]
% disc: [-20 -10 0 10 20]
AVcentroids_allCombs = NaN(3,36); ExpInfo.AVcentroids_allCombs = NaN(3,24);
AVcentroids_allCombs(1:2,:) = combvec(ExpInfo.centroids, ExpInfo.centroids);
AVcentroids_allCombs(3,:)   = AVcentroids_allCombs(2,:) - AVcentroids_allCombs(1,:);
[temp,order]                = sort(AVcentroids_allCombs(3,:)); %sort with disc level
AVcentroids_allCombs        = AVcentroids_allCombs(:,order);
[ridx,cidx] = find(AVcentroids_allCombs(3,:)<=20 & AVcentroids_allCombs(3,:)>=-20);
ExpInfo.AVcentroids_allCombs = AVcentroids_allCombs(1:2,cidx); %24 pairs in total
ExpInfo.AVcentroids_allCombs(3,:) = ExpInfo.AVcentroids_allCombs(2,:) -...
    ExpInfo.AVcentroids_allCombs(1,:); %24 AV pairs with disc levels 
% 1st row: auditory centroids
% 2nd row: corresponding visual centroids
% 3rd row: disc
AVcentroids_allCombsIdx = NaN(3,24);
for i = 1:2
    for j = 1:24
        AVcentroids_allCombsIdx(i,j) = find(ExpInfo.centroids == ExpInfo.AVcentroids_allCombs(i,j));
    end
end     
AVcentroids_allCombsIdx(3,:) = ExpInfo.AVcentroids_allCombs(3,:);
% 1st row: auditory centroid idx
% 2nd row: corresponding visual centroid idx
% 3rd row: disc


% Trial conditions for all 800 trials (condition idx: 1-25, these are the column
% indeces of ExpInfo.AVpairs_allComb. Each col contains a disc idx and a corr idx)
% For each block, each trial type is presented 200/25 = 8 times
ExpInfo.AVpairs_order     = [];
for i = 1:ExpInfo.numReps
    ExpInfo.AVpairs_order = [ExpInfo.AVpairs_order, randperm(ExpInfo.numAVpairs)];
end
% For ExpInfo.trialConditions, 
% 1st row: A centroid idx; 
% 2nd row: V centroid idx; 
% 3rd row: disc level; 
% 4th row: corr val (use ExpInfo.AVpairs_order to find 
% corresponding disc & corr for each trial
ExpInfo.trialConditions = NaN(4,ExpInfo.numTotalTrials);
for i = 1:ExpInfo.numTotalTrials
    AVpairIdx_temp = ExpInfo.AVpairs_allComb(:,ExpInfo.AVpairs_order(i));
    disc_temp = AVpairIdx_temp(1); %disc idx
    corr_temp = AVpairIdx_temp(2); %corr idx
    [ridx,cidx] = find(AVcentroids_allCombsIdx(3,:)==ExpInfo.disc(disc_temp)); 
    %cidx stores the col idx of the AV pairs (A&V centroid idx) with that disc level 
    ExpInfo.trialConditions(1:2,i) = AVcentroids_allCombsIdx(1:2,randsample(cidx,1));
    ExpInfo.trialConditions(3,i) = ExpInfo.disc(disc_temp);
    ExpInfo.trialConditions(4,i) = ExpInfo.corrVals(corr_temp);
end

% define blocks and break trials
ExpInfo.numBlocks         = 4;
blocks                    = linspace(0,ExpInfo.numTotalTrials,ExpInfo.numBlocks+1); 
%% 
% split all the trials into 4 blocks
ExpInfo.breakTrials       = floor(blocks(2:(end-1)));
ExpInfo.numTrialsPerBlock = ExpInfo.breakTrials(1);

% Tasks
% For loc task, shuffle trial types (if 1: localize A; if 2: localize V)
ExpInfo.order_VSnAS     = [];
if ExpInfo.numReps == 1
    for i = 1:ExpInfo.numTotalTrials/2
        ExpInfo.order_VSnAS = [ExpInfo.order_VSnAS, randperm(2,2)]; 
    end
    ExpInfo.order_VSnAS = [ExpInfo.order_VSnAS,1];
else
    for i = 1:ExpInfo.numTotalTrials/2
        ExpInfo.order_VSnAS = [ExpInfo.order_VSnAS, randperm(2,2)]; 
    end
end
ExpInfo.bool_unityReport  = ones(1,ExpInfo.numTotalTrials); %1: insert unity judgment
ExpInfo.randSampleAVtrain = cell(2,ExpInfo.numTotalTrials); %this stores randomly drawn A/V sequences 
% 1st row: A; 2nd row: V

% Initialize a structure that stores all the responses and response time
Response.trialConditions = NaN(4,size(ExpInfo.trialConditions,2));
Response.AVseqs = NaN(2,length(ExpInfo.randSampleAVtrain));
Response.AVlocTrialOrder = ExpInfo.order_VSnAS;
[Response.trialConditions, Response.AVseqs, Response.localization, Response.RT1, Response.unity, Response.RT2] = ...
    deal(NaN(1,ExpInfo.numTotalTrials)); 


%% Run the experiment by calling the function PresentAVtrains
% start the experiment
HideCursor;
Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],....
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
DrawFormattedText(windowPtr, 'Press any button to start the bimodal localization task.',...
    'center',ScreenInfo.yaxis-ScreenInfo.liftingYaxis,[255 255 255]);
Screen('Flip',windowPtr);

KbWait(-3); WaitSecs(1);
Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
Screen('Flip',windowPtr);

for ii = 1:ExpInfo.numTotalTrials % one trial is one AV train (5 events)
    Acolidx   = ExpInfo.trialConditions(1,ii); %A centroid idx
    Vcolidx   = ExpInfo.trialConditions(2,ii); %V centroid idx
    corr_temp = ExpInfo.trialConditions(4,ii); %corr val of ii trial, updated each trial
    %randomly sample one sequence from the corresponding cols of
    %ExpInfo.Atrain and ExpInfo.Vtrain
    ridx_corr = find(ExpInfo.orderedCorr > corr_temp-1e-5 &...
        ExpInfo.orderedCorr < corr_temp+1e-5); %find the idx of ExpInfo.orderedCorr == corr_temp
    % we will use this idx to locate A/V sequences with this particular
    % corr val. ridx_corr should be 600*1, then randsample one from these
    Arowidx   = randsample(ridx_corr,1);
    Vrowidx   = Arowidx;
    ExpInfo.randSampleAVtrain(1,ii) = ExpInfo.Atrain(Arowidx,Acolidx); 
    ExpInfo.randSampleAVtrain(2,ii) = ExpInfo.Vtrain(Vrowidx,Vcolidx);
    
    %present multisensory stimuli
    [Response.localization(ii), Response.RT1(ii), Response.unity(ii),...
    Response.RT2(ii)] = PresentAVtrains(ii,ExpInfo,ScreenInfo,...
    VSinfo, AudInfo,Arduino,pahandle,windowPtr);   

    %add breaks     
    if ismember(ii,ExpInfo.breakTrials)
        Screen('TextSize', windowPtr, 35);
        Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
        DrawFormattedText(windowPtr, 'You''ve finished one block. Please take a break.',...
            'center',ScreenInfo.yaxis-ScreenInfo.liftingYaxis-30,...
            [255 255 255]);
        DrawFormattedText(windowPtr, 'Press any button to resume the experiment.',...
            'center',ScreenInfo.yaxis-ScreenInfo.liftingYaxis,...
            [255 255 255]);
        Screen('Flip',windowPtr); KbWait(-3); WaitSecs(1);
        Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
        Screen('Flip',windowPtr); WaitSecs(0.5);
    end 
    Response.AVseqs = ExpInfo.randSampleAVtrain;
    Response.trialConditions = ExpInfo.trialConditions;
    Bimodal_localization_data = {ExpInfo, ScreenInfo, VSinfo, AudInfo, Response};
    save(out1FileName,'Bimodal_localization_data');
    
end

%% Delete Arduino
fclose(Arduino);
delete(Arduino)

%% Save data and end the experiment
Bimodal_localization_data = {ExpInfo, ScreenInfo, VSinfo, AudInfo, Response};
save(out1FileName,'Bimodal_localization_data');
Screen('CloseAll'); ShowCursor;

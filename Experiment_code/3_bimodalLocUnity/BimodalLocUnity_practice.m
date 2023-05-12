% This is the main experiment. We present A and V trains of 5 simultaneously,
% with fixed, repetitive timing. We vary the spatial locations of A and V
% within a spatial window of 5, such that the corr between AV trains range
% from [-1,1]. The task is first localize the centroid of A or V, and then
% report unity judgment. 

%% Enter subject's name, setup screen 
clear all; close all; clc; rng('shuffle');
addpath(genpath('/e/3.3/p3/hong/Desktop/Project5/Psychtoolbox'));

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

%% Screen Setup 
Screen('Preference', 'VisualDebugLevel', 1);
Screen('Preference', 'SkipSyncTests', 1);
%[windowPtr,rect] = Screen('OpenWindow', 0, [1,1,1]);
[windowPtr,rect] = Screen('OpenWindow', 0, [0,0,0],[100 100 1000 480]); % for testing
[ScreenInfo.xaxis, ScreenInfo.yaxis] = Screen('WindowSize',windowPtr);
Screen('TextSize', windowPtr, 35) ;   
Screen('TextFont',windowPtr,'Times');
Screen('TextStyle',windowPtr,1); 

[center(1), center(2)]     = RectCenter(rect);
ScreenInfo.xmid            = center(1); % horizontal center
ScreenInfo.ymid            = center(2); % vertical center
ScreenInfo.backgroundColor = 0;
%Screen size by the project = 1024 pixels x 768 pixels
%Screen size in cm = 165 x 123.5
ScreenInfo.numPixels_perCM = 6.2;
ScreenInfo.liftingYaxis    = 226;
ScreenInfo.cursorColor     = [0,0,255]; %A: blue, V:red
ScreenInfo.dispModality    = 'A'; %always localize the auditory component

%fixation locations
ScreenInfo.x1_lb = ScreenInfo.xmid-7; ScreenInfo.x2_lb = ScreenInfo.xmid-1;
ScreenInfo.x1_ub = ScreenInfo.xmid+7; ScreenInfo.x2_ub = ScreenInfo.xmid+1;
ScreenInfo.y1_lb = ScreenInfo.yaxis-ScreenInfo.liftingYaxis-1;
ScreenInfo.y1_ub = ScreenInfo.yaxis-ScreenInfo.liftingYaxis+1;
ScreenInfo.y2_lb = ScreenInfo.yaxis-ScreenInfo.liftingYaxis-7;
ScreenInfo.y2_ub = ScreenInfo.yaxis-ScreenInfo.liftingYaxis+7;

%% Initialise serial object
Arduino = serial('/dev/cu.usbmodemFD131','BaudRate',9600); 
% open for usage
fopen(Arduino);

%% Open speakers and create sound stimuli 
PsychDefaultSetup(2);
% get correct sound card
InitializePsychSound
devices = PsychPortAudio('GetDevices');
our_device=devices(3).DeviceIndex;

%% Make auditory stimuli (beep)
AudInfo.fs                           = 44100;
AudInfo.stimDura                     = 0.1; % ExpInfo.stimFrame * ScreenInfo.ifi; %s, the duration of auditory stimulus
AudInfo.tf                           = 500;
AudInfo.beepLengthSecs               = AudInfo.stimDura;
beep                                 = MakeBeep(AudInfo.tf, AudInfo.beepLengthSecs, AudInfo.fs);
AudInfo.Beep                         = [beep; beep];
pahandle = PsychPortAudio('Open', our_device, [], [], [], 2); %open device

%% Make visual stimuli (gaussian blob)
%calculate visual angle
ExpInfo.sittingDistance              = 113.0;
ExpInfo.leftspeaker2center           = 65.5;
ExpInfo.rightspeaker2center          = 65.5;
ExpInfo.leftmostVisualAngle          = (180/pi) * atan(ExpInfo.leftspeaker2center / ...
                                       ExpInfo.sittingDistance);
ExpInfo.rightmostVisualAngle         = (180/pi) * atan(ExpInfo.leftspeaker2center / ...
                                       ExpInfo.sittingDistance);
%define visual stimuli
VSinfo.scaling                       = 0.4;%0.2; % a ratio between 0 to 1 to be multipled by 255
pblack                               = 1/8; % set contrast to 1*1/8 for the "black" background, so it's not too dark and the projector doesn't complain
VSinfo.Distance                      = linspace(-30,30,16); %in deg
VSinfo.numLocs                       = length(VSinfo.Distance);
VSinfo.numFrames                     = 6;
%VSinfo.duration                      = VSinfo.numFrames * ifi; %s
VSinfo.width                         = 201; %(pixel) Increasing this value will make the cloud more blurry (arbituary value)
VSinfo.boxSize                       = 101; %This is the box size for each cloud (arbituary value)
%set the parameters for the visual stimuli
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

    
%% Define experiment information

% -------------------- Correlation ----------------------------------------
% Create auditory and visual trains with fixed corrs. Shuffled AV sequences
% with randomized corr values are saved in ExpInfo.Atrain and ExpInfo.Vtrain, and the
% corresponding corr value of all AV pairs are saved in ExpInfo.corrAV (ordered). 
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
% CorrReshape = reshape(Corr, 1,[]);
% figure; histogram(CorrReshape,20)
    
% construct two arrays with A,V sequences with fixed corr
CorrVal = -1:0.1:1;
nCorr = length(CorrVal); 
nCorrRep = 120; % number of sequences for each correlation
CorrSortedA = cell(nCorrRep,nCorr); %120*21
CorrSortedV = cell(nCorrRep,nCorr);
idxA = NaN(nCorrRep,nCorr); %120*21
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

% reshape and shuffle
Atrain_temp         = reshape(CorrSortedA, [], 1); %2520*1
Vtrain_temp         = reshape(CorrSortedV, [], 1); %2520*1
randidx             = randperm(2520);
ExpInfo.Atrain      = Atrain_temp(randidx);
ExpInfo.Vtrain      = Vtrain_temp(randidx);

% check corr
ExpInfo.CorrAV = NaN(2520,1);
for i = 1:2520
    ExpInfo.CorrAV(i) = corr(ExpInfo.Atrain{i}',ExpInfo.Vtrain{i}');
end

% ------------------ Other experiment information ------------------------
ExpInfo.numTrials         = 1;%for each AV pair
ExpInfo.numAVpairs        = length(ExpInfo.CorrAV); %2520 possible pairs 
ExpInfo.numTotalTrials    = ExpInfo.numTrials * ExpInfo.numAVpairs;
ExpInfo.bool_unityReport  = ones(1,ExpInfo.numTotalTrials);%1: insert unity judgment
%initialize a structure that stores all the responses and response time
[Response.localization, Response.RT1, Response.unity, Response.RT2] = ...
    deal(NaN(1,ExpInfo.numTotalTrials));  
  

%% Run the experiment by calling the function PresentAVtrains
% start the experiment
DrawFormattedText(windowPtr, 'Press any button to start the bimodal localization task.',...
    'center',ScreenInfo.yaxis-ScreenInfo.liftingYaxis,[255 255 255]);
Screen('Flip',windowPtr);
KbWait(-3); WaitSecs(1);
Screen('Flip',windowPtr);

for ii = 1:2%ExpInfo.numTotalTrials % one trial is one AV train (5 events)
    %present multisensory stimuli
        [Response.localization(ii), Response.RT1(ii), Response.unity(ii),...
        Response.RT2(ii)] = PresentAVtrains(ii,nEvents,ExpInfo,ScreenInfo,...
        VSinfo, AudInfo,Arduino,pahandle,windowPtr);   
end

%% Disconnect arduino
fclose(Arduino);
delete(Arduino)

%% Save data and end the experiment
BimodalLocUnity_practice_data = {ExpInfo, ScreenInfo, VSinfo, ...
    AudInfo, Response};
save(out1FileName,'BimodalLocUnity_practice_data');
Screen('CloseAll');

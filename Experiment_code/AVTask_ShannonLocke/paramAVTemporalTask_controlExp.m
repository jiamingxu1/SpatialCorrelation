function [designMat,expDesign,VIS,AUD,designMat_Legend,all_frameType,all_ear] = paramAVTemporalTask_controlExp(hardware)

% Created by SML May 2016

% --------------
% EXP Parameters
% --------------

% General Parameters
expDesign.repeats = [15 75]; % number of repeats per condition {conflictNo ConflictYes}
expDesign.trialDur = 2; % trial duration in seconds
expDesign.ISI = 1; % interstimulus interval in seconds
expDesign.fixCueTime = 0.2; % Duration of fixation cross presentation before presenting stimulus

% Independent Variables in experiment:
opt_rate = [8, 10, 12, 14]; % click-flash rates
opt_temporalConflictYN = [0, 1]; % correlated or not
designMat_Legend = {'Rate';'Temporal Conflict';'Maximum AV Offset';'Proportion Synchronous'};

% Make Design Matrix:
designMat1 = makeDesignMat({opt_rate, opt_temporalConflictYN(1)},expDesign.repeats(1));
designMat2 = makeDesignMat({opt_rate, opt_temporalConflictYN(2)},expDesign.repeats(2));
designMat = ShuffleRC([designMat1; designMat2]);
expDesign.nTrials = size(designMat,1); % total number of trials
% 30 no-conflict/rate, 150 conflict/rate, 17% no conflict, @ 10 trials/min w. 720 trials each session is 36 min 

% Poisson Process Parameters:
expDesign.nOff = 2; % Number of off frames for each event
expDesign.tStep = (expDesign.nOff+1)/hardware.fps; % time steps for Poisson process

% --------------------------------
% Fixed Visual Stimulus Parameters
% --------------------------------

VIS = get_viewingConditions(hardware,'SOUNDBOOTH');

% Parameters in degree of visual angle:
VIS.sizeTex_deg = 20; % Size of blob texture
VIS.SD_deg = 2.5; % 1.3; % Standard deviation of gaussian blob

% Calculate the number of pixels:
VIS.SD_pix = VIS.SD_deg * VIS.pixPerDeg;
VIS.sizeTex_pix = round(VIS.sizeTex_deg * VIS.pixPerDeg);
if VIS.sizeTex_pix/2 == round(VIS.sizeTex_pix/2) 
    VIS.sizeTex_pix = VIS.sizeTex_pix + 1; % make odd number
end

% Half length of fixation cross in pixels:
VIS.crossLen = 8; 

% Placement of texture:
% (Because the speaker overlaps with the lower 4.5cm of the screen, we want
% to place the visual stimulus directly above the speaker. The blurring
% however means that the actual texture needs to be lower. The speaker
% overlap parameter is set manually.
VIS.speakerOverlap_cm = 3;
VIS.speakerOverlap_pix = round(VIS.speakerOverlap_cm * VIS.pixPerCm);
VIS.textureLoc = zeros(4,1); % preallocate
VIS.textureLoc(1) = hardware.sCenter(1) - (VIS.sizeTex_pix-1)/2; % H placement, top left corner
VIS.textureLoc(2) = hardware.screenRes(2) - VIS.sizeTex_pix - VIS.speakerOverlap_pix; % V placement, top left corner
VIS.textureLoc(3) = hardware.sCenter(1) + (VIS.sizeTex_pix-1)/2; % H placement, bottom right corner
VIS.textureLoc(4) = hardware.screenRes(2) - VIS.speakerOverlap_pix; % V placement, bottom right corner
VIS.fixCrossLoc = VIS.sizeTex_pix - hardware.screenRes(2)/2 + VIS.speakerOverlap_pix - VIS.crossLen - 1; % vertical displacement of fix cross from top of blob texture

% ----------------------------------
% Fixed Auditory Stimulus Parameters
% ----------------------------------

AUD.freq = 48000; % sampling frequency
AUD.clickDur = 1/hardware.fps; % Duration of trial in sec
AUD.alertBeepFreq = 900; % warning tone frequency in Hz
AUD.cosWin = 5; % 5ms cosine window in samples
AUD.lowF = 200; % Lowest frequency in broadband signal
AUD.highF = 10000; % Highest frequency in broadband signal
AUD.volScaleFactor = [0.87 0.65]; % How much to scale lateral and central speaker, respectively, to have matched sound intensity

% ------------------
% Generate sequences
% ------------------
v2struct(expDesign)

% Storage vectors:
nFrames = trialDur * hardware.fps; % number of frames
all_frameType = NaN(nFrames,expDesign.nTrials);
all_ear = NaN(nFrames,expDesign.nTrials);
all_maxOffset = NaN(expDesign.nTrials,1);
all_propSync = NaN(expDesign.nTrials,1);

for ii = 1:expDesign.nTrials
    
    currRate = designMat(ii,1); % Rate for this trial?
    tempSyncYN = 1 - designMat(ii,2); % Synchronous or not?
    
    % Generate sequences with max offset less than 0.2s
    if tempSyncYN == 1
        [frameType,ear] = oneStreamAV_PoissonProcess(currRate,trialDur,tStep,1,nOff,0);
        all_maxOffset(ii) = 0;
        all_propSync(ii) = 1;
    else 
        ok = 0;
        while ok == 0
            [frameType,~] = oneStreamAV_PoissonProcess(currRate,trialDur,tStep,1,nOff,0);
            [~,ear] = oneStreamAV_PoissonProcess(currRate,trialDur,tStep,1,nOff,0);
            [maxOffset, ~, propSync] = get_maxOffset(frameType-1,ear,hardware.fps);
            if maxOffset <= 0.2 % check max offset
                ok = 1;
            end
        end
        all_maxOffset(ii) = maxOffset;
        all_propSync(ii) = propSync;
    end
    
    % Save sequence:
    all_frameType(:,ii) = frameType' - 1;
    all_ear(:,ii) = ear';
    
end

% Add sequence statistics to design matrix:
designMat = [designMat, all_maxOffset, all_propSync];

% % have a look at the sequence statistics in R:
% rate = designMat(:,1);
% tempConflictYN = designMat(:,2);
% maxOffset = designMat(:,3);
% propSync = designMat(:,4);
% T = table(rate, tempConflictYN, maxOffset, propSync);
% filesave = '/Users/shannonlocke/GoogleDrive/Library/Experiments/AudiovisualRateDiscrimination/DataAnalysis/RateJNDinR/data_raw_rateJND/controlExpData2.txt';
% writetable(T,filesave,'Delimiter',' ')

end
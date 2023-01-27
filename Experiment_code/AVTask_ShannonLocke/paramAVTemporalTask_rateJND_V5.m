function [designMat,expDesign,VIS,AUD,designMat_Legend] = paramAVTemporalTask_rateJND_V5(hardware,session)

% --------------
% EXP Parameters
% --------------

% Variable Parameters:
switch session
    case 1
        sOpt = [1 1];
    case 2
        sOpt = [1 0];
    case 3
        sOpt = [0 1];
    case 4
        sOpt = [0 0];
end
expDesign.tempSyncYN = sOpt(1); % Are the visual and auditory modalities temporally synchronous?
expDesign.spatialSyncYN = sOpt(2); % Is the sound presented via speakers (alternative = headphones)?

% General Parameters
expDesign.repeats = 200; % number of trials per staircase
expDesign.trialDur = 2; % trial duration in seconds
expDesign.ISI = 1; % interstimulus interval in seconds
expDesign.fixCueTime = 0.2; % Duration of fixation cross presentation before presenting stimulus
expDesign.refRate = 8; % standard for the comparison to standard task

% Independent Variables in experiment:
opt_modOpt = 1:3; % modality of presentation (visual, auditory, or multisensory)
designMat_Legend = {'Lambda_Reference';'Stimulus Modality';'Trial Duration'};

% Make Design Matrix:
conditions = {opt_modOpt};
designMat = makeDesignMat(conditions,expDesign.repeats);
expDesign.nTrials = size(designMat,1); % total number of trials

% Poisson Process Parameters:
expDesign.nOff = 2; % Number of off frames for each event
expDesign.tStep = (expDesign.nOff+1)/hardware.fps; % time steps for Poisson process

% Add reference rate to beginning of design matrix:
designMat = [repmat(expDesign.refRate,expDesign.nTrials,1) designMat];

% Add duration jitter:
expDesign.jitterRange = [-0.25 0.25];
jitterVal = diff(expDesign.jitterRange) * rand(expDesign.nTrials,1);
designMat(:,3) = jitterVal + expDesign.trialDur + expDesign.jitterRange(1);
designMat(:,3) = round(designMat(:,3)/expDesign.tStep) * expDesign.tStep;

% Choose randomly side of presentation for asynchronous condition:
% expDesign.spatLoc = randi(2,[expDesign.nTrials,1]);
% [1 = RHS, 2 = LHS]

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
AUD.imposedDelay_s = 0.024 - AUD.clickDur;
AUD.imposedDelay_samples = round(AUD.imposedDelay_s * AUD.freq);

end
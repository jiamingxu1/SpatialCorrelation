% This is the main experiment. We present A and V trains of 5 simultaneously,
% with fixed, repetitive timing. We vary the spatial locations of A and V
% within a spatial window of 5, such that the corr between AV trains range
% from [-1,1]. The task is first localize the centroid of A or V, and then
% report unity judgment. 

%% Enter subject's name, setup screen 
clear all; close all; clc; rng('shuffle');
addpath(genpath('/e/3.3/p3/hong/Desktop/Project5/Psychtoolbox'));

display = 1; % 1:testing room; 2:my laptop
ExpInfo.subjID = [];
while isempty(ExpInfo.subjID) == 1
    try ExpInfo.subjID = input('Please enter participant ID#: ') ; %'s'
    catch
    end
end
ScreenInfo = setup_screen(display);
kb.escKey = KbName('ESCAPE');

%% initialise serial object
Arduino = serial('/dev/cu.usbmodemFD131','BaudRate',9600); 
% open for usage
fopen(Arduino);

%% Open speakers and create sound stimuli 
PsychDefaultSetup(2);
% get correct sound card
InitializePsychSound
devices = PsychPortAudio('GetDevices');
our_device=devices(3).DeviceIndex;

%% make auditory stimuli (gaussian white noise)
AudInfo.fs                  = 44100;
audioSamples                = [linspace(1,AudInfo.fs,AudInfo.fs);
    linspace(1,AudInfo.fs,AudInfo.fs)]; 
standardFrequency_gwn       = 10;
AudInfo.adaptationDuration  = 0.1; %0.05 %the burst of sound will be displayed for 40 milliseconds
duration_gwn                = size(audioSamples,2)*AudInfo.adaptationDuration;
timeline_gwn                = linspace(1,duration_gwn,duration_gwn);
sineWindow_gwn              = sin(standardFrequency_gwn/2*2*pi*timeline_gwn/AudInfo.fs); 
carrierSound_gwn            = randn(1, max(timeline_gwn));
AudInfo.intensity_GWN       = 15;
AudInfo.GaussianWhiteNoise  = [AudInfo.intensity_GWN.*sineWindow_gwn.*carrierSound_gwn;...
    AudInfo.intensity_GWN.*sineWindow_gwn.*carrierSound_gwn];
pahandle = PsychPortAudio('Open', our_device, [], [], [], 2); %open device

%% make auditory stimuli (beep)
AudInfo.fs                           = 44100;
AudInfo.stimDura                     = 0.1; % ExpInfo.stimFrame * ScreenInfo.ifi; %s, the duration of auditory stimulus
AudInfo.tf                           = 500;
AudInfo.beepLengthSecs               = AudInfo.stimDura;
beep                                 = MakeBeep(AudInfo.tf, AudInfo.beepLengthSecs, AudInfo.fs);
AudInfo.Beep                         = [beep; beep];
pahandle = PsychPortAudio('Open', our_device, [], [], [], 2); %open device

%% Create auditory and visual trains with fixed corrs
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
ATrain_temp = reshape(CorrSortedA, [], 1); %2520*1
VTrain_temp = reshape(CorrSortedV, [], 1); %2520*1
randidx     = randperm(2520);
ATrain      = ATrain_temp(randidx);
VTrain      = VTrain_temp(randidx);

% check corr
CorrAV = NaN(2520,1);
for i = 1:2520
    CorrAV(i) = corr(ATrain{i}',VTrain{i}');
end

 
%% present AV trains
for i=1:20 %4 blocks
    for j=1:nEvents
    input_on = ['<',num2str(1),':',num2str(audTrain(i,j)),'>'];
    fprintf(Arduino,input_on);
    %draw (buffer)
    %flip here (stimulus onset timing)
    %flip (offset)
    PsychPortAudio('FillBuffer',pahandle, AudInfo.Beep);
    %PsychPortAudio('FillBuffer',pahandle, AudInfo.GaussianWhiteNoise);
    PsychPortAudio('Start',pahandle,1,0,0);
    WaitSecs(0.2)
    input_off = ['<',num2str(0),':',num2str(audTrain(i,j)),'>'];
    fprintf(Arduino,input_off);   
    PsychPortAudio('Stop',pahandle);
    WaitSecs(0.15)
    end
    WaitSecs(0.5)
end

%%
fclose(Arduino)
delete(Arduino)


%% Play bimodal aud vis trains

kb.keyIsDown = 0; % set escape key
kb.keyCode = zeros(1,256);

iT = 1; 
while ~kb.keyCode(kb.escKey) || iT <= ExpInfo.nTrial
    
    [kb.keyIsDown, kb.secs, kb.keyCode, kb.deltaSecs] = KbCheck(-1);

    currentAud = ExpInfo.design(iT);
    ExpInfo.result(iT,1) = ExpInfo.actualAud(currentAud);
    freq = freqMat(:,1);
    wavedata = yMat{ExpInfo.fileOrder(currentAud),1};
    
    % show fixation
    Screen('FillRect', ScreenInfo.windowPtr,[255 255 255], [ScreenInfo.x1_lb,ScreenInfo.y1_lb,...
        ScreenInfo.x1_ub, ScreenInfo.y1_ub]);
    Screen('FillRect', ScreenInfo.windowPtr,[255 255 255], [ScreenInfo.x2_lb,ScreenInfo.y2_lb,...
        ScreenInfo.x2_ub, ScreenInfo.y2_ub]);
    Screen('Flip',ScreenInfo.windowPtr); WaitSecs(0.5);
    Screen('Flip',ScreenInfo.windowPtr); WaitSecs(0.5);
    
    start playing
    pahandle = PsychPortAudio('Open', our_device, [], 0, freq, nrchannels);
    PsychPortAudio('FillBuffer', pahandle, GWN);
    PsychPortAudio('Start', pahandle, ExpInfo.repetitions, 0, 1);   
    
    PsychPortAudio('FillBuffer', pahandle, GWN);
    PsychPortAudio('Start', pahandle, 1, 0, 0);
    WaitSecs(AudInfo.adaptationDuration);
    PsychPortAudio('Stop', pahandle);
    %black screen for 0.5 seconds
    Screen('Flip',windowPtr);
    WaitSecs(0.5);
    
    
% get mouse location

yLoc = ScreenInfo.yaxis-ScreenInfo.liftingYaxis;
SetMouse(randi(ScreenInfo.xmid*2,1), yLoc, ScreenInfo.windowPtr); buttons = 0;

while sum(buttons)==0
    [x,~,buttons] = GetMouse; HideCursor;
    Screen('FillRect', ScreenInfo.windowPtr, [0 300 0],[x-3 yLoc-24 x+3 yLoc-12]);
    Screen('FillPoly', ScreenInfo.windowPtr, [0 300 0],[x-3 yLoc-12; x yLoc; x+3 yLoc-12]);
    Screen('Flip',ScreenInfo.windowPtr,0,0);
    
    [kb.keyIsDown, kb.secs, kb.keyCode, kb.deltaSecs] = KbCheck(-1);
    
    if kb.keyCode(kb.escKey)
        Screen('CloseAll');
    end
    
end

% collect responses
Response_pixel = x;
Response_cm    = (Response_pixel -  ScreenInfo.xmid)/ScreenInfo.numPixels_perCM;
ExpInfo.result(iT,2)   = rad2deg(atan(Response_cm/ExpInfo.sittingDistance));  
    
iT = iT+1;

    if iT > ExpInfo.nTrial
         break
    end
    
end
Screen('Flip',ScreenInfo.windowPtr); WaitSecs(0.5);
Screen('CloseAll');

%% Save data and end the experiment
UniAlocalization_data = {ExpInfo,ScreenInfo}; % result in ExpInfo
save(out1FileName,'UniAlocalization_data');
Screen('CloseAll');

%% Unimodal auditory localization
% Subjects localize the location of each auditory event from the previous
% recording

clear; close all; clc; rng('shuffle');

%% Enter participant number & specify display
display = 1; % 1:testing room; 2:my laptop
% ExpInfo = setup_exp(dislay);

ExpInfo.subjID = [];
while isempty(ExpInfo.subjID) == 1
    try ExpInfo.subjID = input('Please enter participant ID#: ') ; %'s'
    catch
    end
end

out1FileName   = ['UniAlocalization_sub',num2str(ExpInfo.subjID)];

%% Set up variables 
ExpInfo = setup_param(display); 
[yMat, freqMat, nrchannels] = load_aud(ExpInfo); % Load the sound files 
ScreenInfo = setup_screen(display);
kb.escKey = KbName('ESCAPE');


%% Play audio files

PsychDefaultSetup(2);
InitializePsychSound
devices = PsychPortAudio('GetDevices');
device = devices(end).DeviceIndex; % my laptop

kb.keyIsDown = 0; % set escape key
kb.keyCode = zeros(1,256);

iT = 1; 
while ~kb.keyCode(kb.escKey) || iT <= ExpInfo.nTrial
    
    [kb.keyIsDown, kb.secs, kb.keyCode, kb.deltaSecs] = KbCheck(-1);

    currentAud = ExpInfo.design(iT);
    ExpInfo.result(iT,1) = ExpInfo.actualAud(currentAud);
    freq = freqMat(:,1);
    wavedata = yMat{currentAud,1};
    
    % show fixation
    Screen('FillRect', ScreenInfo.windowPtr,[255 255 255], [ScreenInfo.x1_lb,ScreenInfo.y1_lb,...
        ScreenInfo.x1_ub, ScreenInfo.y1_ub]);
    Screen('FillRect', ScreenInfo.windowPtr,[255 255 255], [ScreenInfo.x2_lb,ScreenInfo.y2_lb,...
        ScreenInfo.x2_ub, ScreenInfo.y2_ub]);
    Screen('Flip',ScreenInfo.windowPtr); WaitSecs(0.5);
    Screen('Flip',ScreenInfo.windowPtr); WaitSecs(0.5);
    
    % start playing
    pahandle = PsychPortAudio('Open', device, [], 0, freq, nrchannels);
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    PsychPortAudio('Start', pahandle, ExpInfo.repetitions, 0, 1);   
    
% get mouse location

yLoc = ScreenInfo.yaxis-ScreenInfo.liftingYaxis;
WaitSecs(0.5)
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
ShowCursor;


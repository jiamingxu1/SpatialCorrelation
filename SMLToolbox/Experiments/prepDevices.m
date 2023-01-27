function [hardware] = prepDevices(visDisp,audDisp,kbYN,mouseYN)
% [hardware] = PREPDEVICES(visDisp,audDisp,kbYN,mouseYN) will prepare and 
% run checks on the standard computer hardware prior to starting an 
% experiment: monitor, audio device, keyboard, and mouse.
%
% Created by SML Dec 2014, updated for optional keyboard and mouse options

if nargin < 4
    mouseYN = 0; % NO MOUSE
    if nargin < 3
        kbYN = 1; % YES KEYBOARD
        if nargin < 2
            audDisp = 0; % NO AUDITORY 
           if nargin < 1
               visDisp = 1; % YES VISUAL
           end
        end
    end
end

% -------
% Monitor
% -------

if visDisp
    
    try
        
        AssertOpenGL;
        screens = Screen('Screens');
        hardware.screenID = max(screens);
        [w, hardware.screenRes] = Screen('OpenWindow', hardware.screenID, 0);
        
        % Screen center:
        [hardware.sCenter(1), hardware.sCenter(2)] = RectCenter(hardware.screenRes);
        hardware.screenRes = hardware.screenRes(3:4);
        
        % Get frame rate:
        hardware.fps = Screen('FrameRate',w); % nominal frame rate
        hardware.flipInterval = Screen('GetFlipInterval', w); % True flip interval
        if hardware.fps == 0 % no nominal frame rate set
            hardware.fps = round(1/hardware.flipInterval); % Calculate frame rate
        end;
        
    catch
        error('Error in initial screen checks.')
    end

    sca
    
end

% ----------
% Sound Card
% ----------

if audDisp
    
    InitializePsychSound(1);
    % Initialize sounddriver. Note: 1 is the 'reallyneedlowlatency' flag,
    % which sets the driver to use the lowest possible latency and highest
    % timing precision.
    
    hardware.nChannels = 2;
    % Almost always will use 2 channels. Can change after calling prepExp
    % if necessary.
    
    hardware.devMode = 1+8;
    % Note that the mode options are: 1) sound playback only, 2) audio capture,
    % 3) simultaneous capture and playback. Adding 8 to the device mode will
    % assign a device to be a master device, which can then control multiple
    % slave devices.
    
    hardware.rlc = 1;
    % reqlatencyclass. Level 0 means: Don't care about latency, this mode
    % works always and with all settings, plays nicely with other sound applications.
    % Level 1 (the default) means: Try to get the lowest latency that is possible
    % under the constraint of reliable playback, freedom of choice for all parameters
    % and interoperability with other applications. Level 2 means: Take full control
    % over the audio device, even if this causes other sound applications to fail or
    % shutdown. Level 3 means: As level 2, but request the most aggressive settings
    % for the given device. Level 4: Same as 3, but fail if device can't meet the
    % strictest requirements.
      
end

% --------
% Keyboard
% --------

if kbYN == 1
    KbName('UnifyKeyNames');
end

% -----
% Mouse
% -----

if mouseYN == 1
    
else
    HideCursor; 
end

end
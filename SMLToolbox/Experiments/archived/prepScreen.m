function [w,hardware] = prepScreen(skipSyncChecksYN)
% 
% Created by SML Nov 2020
% No longer in use, see openExpScreen.m

AssertOpenGL;
if skipSyncChecksYN; Screen('Preference', 'SkipSyncTests', 1); end
screens = Screen('Screens');
hardware.screenID = max(screens);
[w, hardware.screenRes] = Screen('OpenWindow', hardware.screenID, [127.5 127.5 127.5]);
Priority(MaxPriority(w));
Screen('Flip', w); % do initial flip

% Screen center:
[hardware.sCenter(1), hardware.sCenter(2)] = RectCenter(hardware.screenRes);
hardware.screenRes = hardware.screenRes(3:4);

% Get frame rate:
hardware.fps = Screen('FrameRate',w); % nominal frame rate
hardware.flipInterval = Screen('GetFlipInterval', w); % True flip interval
if hardware.fps == 0 % no nominal frame rate set
    hardware.fps = round(1/hardware.flipInterval); % Calculate frame rate
end
if skipSyncChecksYN; hardware.fps = 60; end

end
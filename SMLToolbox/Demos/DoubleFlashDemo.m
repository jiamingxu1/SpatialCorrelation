%% Double flash illusion demo
%
% This file will play a sequence of flash-beep combinations. In some, the
% number of flashes and beeps will be two, in others two beeps will be
% paird with a single flash. The presentation will pause after each
% stimulus so the observer can guess the number of true flashes. After a
% key press, the answer will be revealed.
%
% Created by SML May 2015.

% -------------------------------
% HARDWARE AND VIEWING CONDITIONS
% -------------------------------

% Prepare devices and experimental set up info:
hardware = prepDevices(1,1);
VIS = get_viewingConditions(hardware,'DESK_LANDY_LAB');

% Keyboard inputs:
kSpaceBar = KbName('space');
kLeft = KbName('leftarrow');
kRight = KbName('rightarrow');

% ---------------
% VISUAL STIMULUS
% ---------------

% Visual stimulus parameters in degree of visual angle:
sizeTex_deg = 10; % Size of blob texture
SD_deg = 1.3; % Standard deviation of gaussian blob

% Calculate the number of pixels:
sizeTex_pix = round(sizeTex_deg * VIS.pixPerDeg);
if sizeTex_pix/2 ~= round(sizeTex_pix/2)
    sizeTex_pix = sizeTex_pix + 1; % make odd number
end
SD_pix = SD_deg * VIS.pixPerDeg;

% -----------------
% AUDITORY STIMULUS
% -----------------

% Parameters:
freq = 48000; % sampling frequency
clickDur = 1/hardware.fps; % Duration of trial in sec
tone = 700; % tone frequency in Hz
cosWin = 10; % 10ms cosine window in samples

% Click:
t = 0:1/freq:clickDur; % samples
click = sin(2*pi*tone*t); % sine wave at tone frequency
click = applyCosRamp_ms(click,cosWin,freq); % ramped
gapDur = clickDur; % duration between clicks
gap = zeros(1,gapDur*freq); % silence between clicks
s = [click gap click]; % sound stimulus
player = audioplayer(s,freq); % Feed sound to buffer

% ---------------
% OPEN THE SCREEN
% ---------------

AssertOpenGL;
screens=Screen('Screens');
screenID=max(screens);
w = Screen('OpenWindow', screenID, 127);
Priority(MaxPriority(w));
Screen('Flip', w); % do initial flip

Screen('TextSize',w, 18);
instrText = 'Was there 1 flash or 2?';
Screen('FillRect', w, [127 127 127]);
DrawFormattedText(w, instrText, 'center', 'center', 255)
Screen('Flip', w); % present instructions
pause

Screen('FillRect', w, [127 127 127]); % clear Screen
Screen('Flip', w);

% Create texture:
frame = quick_makeGausBlob(sizeTex_pix,SD_pix);
frame2 = 127 * ones(size(frame));
blob = Screen('MakeTexture', w, frame);
blank = Screen('MakeTexture', w, frame2);
seq = [blank blob blank blank; blob blank blob blank];

% ---------------
% PRESENT STIMULI
% ---------------

keepGoing = 1;
while keepGoing == 1
    
    % Present a stimulus?
    keepGoing = input('\n\nKeep going [Enter=yes, 0=no]?   ');
    if keepGoing == 0
        sca
        return
    else 
        keepGoing = 1;
    end
    
    % Randomly select the number of flashes:
    nFlash = randi(2);
    
    % Play auditory stimulus:
    play(player);
    
    % Present visual stimulus:
    for ii = 1:4
        Screen('DrawTexture', w, seq(nFlash,ii));
        Screen('Flip', w);
    end
    
    % Present feedback:
    pause
    feedbackText = sprintf('Number of flashes: %i',nFlash);
    Screen('FillRect', w, [127 127 127]);
    DrawFormattedText(w, feedbackText, 'center', 'center', 255)
    Screen('Flip', w); % present feedback
    WaitSecs(0.5);
    Screen('FillRect', w, [127 127 127]); % clear Screen
    Screen('Flip', w);
    
end

sca
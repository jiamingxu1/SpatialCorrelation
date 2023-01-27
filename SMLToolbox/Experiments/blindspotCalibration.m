function [pixPerDeg,distToBlindspot] = blindspotCalibration(N,w,hardware)
% This function will use an estimate of the blindspot location to calculate
% the pixels/deg for a given set up. This code is heavily inspired by the
% paper by Li, Joo, Yeatman, & Renecke (2020) in Scientific Reports. There
% they used this technique to estimate viewing distance, here we are doing
% this to get pix/deg.
%
% Created by SML March 2021

% Defaults (trigger screen setup if empty):
if nargin < 3
    hardware = [];
    if nargin < 2
        w = [];
        if nargin < 1
            N = 10; % 10 repeats
        end
    end
end

% Do screen setup if necessary (stand-alone mode):
if isempty(hardware)
    skipSyncChecksYN = true;
    [w, hardware] = openExpScreen(skipSyncChecksYN);
    closeScreenYN = true;
else
    closeScreenYN = false;
end

%% SET-UP

% Static fixation dot parameters:
fixPos = [1.25*hardware.sCenter(1), hardware.sCenter(2)]; % 3/4 horizontally, half-height
fixCol = 0; % black
fixSize = 15;

% Moving probe dot parameters:
probeSpeed_pixPerSec = 150; % probe speed in pixels per second
probeSpeed = probeSpeed_pixPerSec/hardware.fps; % now in pixels per frame
probeCol = [255 50 50]; % red
probeSize = 30;

% Calibration procedure parameters:
probeOffset = 20; % Number of frames offset
nFrames = floor(fixPos(1)/probeSpeed)-probeOffset; % number of frames to reach screen's left edge

% Set -up for blindspot measurement procedure:
blindspotPos = NaN([1,N]);
spaceKey = KbName('SPACE');
maxKeyWaitTime = 0.8 * (1/(hardware.fps));
Screen('FillRect', w, [127 127 127])
Screen('Flip', w);

%% TAKE MEASUREMENTS

InstructionsText = ['Before starting, we must take some measurements to calibrate\n'... 
                    'the stimuli to your display.\n\n (press space to continue)'];
quickDrawText(w,InstructionsText,'keyPress',spaceKey);
InstructionsText = ['To do this, we need to measure your blindspot location.\n\n'...
                    'First, get into a comfortable position with your chair and monitor.\n'... 
                    'Try your best to not move from this position until the experiment is over.\n'...
                    'Cover your right eye with your hand. Fixate your left eye on the black dot.\n'... 
                    'As soon as the red dot disappears, press the space key.\n\n You will do this '...
                    num2str(N) ' times. Get ready!\n\n (press space to continue)'];
quickDrawText(w,InstructionsText,'keyPress',spaceKey);

% Run blindspot measurement procedure:
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % prep for smoothed dots
for mm = 1:N % EACH measurement
    
    probePos = fixPos - [probeOffset*probeSpeed, 0]; % start near fixation dot
    responseYN = false; % response recorded
    
    for ff = 1:nFrames % EACH frame
        
        % Present stimulus:
        Screen('DrawDots', w, fixPos, fixSize, fixCol, [0 0], 2); % draw fixation dot
        Screen('DrawDots', w, probePos, probeSize, probeCol, [0 0], 2); % draw probe dot
        Screen('Flip', w);
        
        % Pause if first frame:
        if ff == 1
            WaitSecs(1); % give a 1 second break between measures
        end
        
        % Collect response if any:
        timeout = false;
        tStart = GetSecs;
        while ~timeout
            [keyIsDown,keyTime,keyCode] = KbCheck;
            if keyIsDown
                key = find(keyCode);
                if key == spaceKey; blindspotPos(mm) = probePos(1); responseYN = true; end
                break
            end
            if (keyTime - tStart) > maxKeyWaitTime; timeout = true; end
        end
        if responseYN; break; end
        
        % update probe dot location:
        probePos = probePos - [probeSpeed, 0];
        
    end
end

CalibrationFinishedText = 'Calibration complete!\n\n (press space to continue)';
quickDrawText(w,CalibrationFinishedText,'keyPress',spaceKey);
if closeScreenYN; sca; end % close screen if running in stand-alone mode

%% COMPUTE PIXELS PER DEGREE:

% Compute average pixPerDeg:
distToBlindspot = fixPos(1) - blindspotPos;
pixPerDeg = median(distToBlindspot)/13.5; 

% Report results:
disp('The measurements of the distance to the blindspot were (in pixels):')
disp(distToBlindspot)
disp('The mean distance is:')
disp(mean(distToBlindspot))
disp('with a standard deviation of:')
disp(std(distToBlindspot))
disp('Giving a pixels per degree measure of:')
disp(pixPerDeg)

end
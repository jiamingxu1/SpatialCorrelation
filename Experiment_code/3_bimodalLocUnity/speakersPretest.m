%% Test all speakers to make sure everything works
addpath(genpath('/e/3.3/p3/hong/Desktop/Project5/Psychtoolbox'));

%% Initialise serial object
Arduino = serial('/dev/cu.usbmodemFD131','BaudRate',9600); 
%open for usage
fopen(Arduino);

%% Open speakers and create sound stimuli 
PsychDefaultSetup(2);
% get correct sound card
InitializePsychSound
devices = PsychPortAudio('GetDevices');
our_device=devices(3).DeviceIndex;

%% make auditory stimuli 
AudInfo.fs                           = 44100;
AudInfo.stimDura                     = 0.1; % ExpInfo.stimFrame * ScreenInfo.ifi; %s, the duration of auditory stimulus
AudInfo.tf                           = 400; %500
AudInfo.beepLengthSecs               = AudInfo.stimDura;
beep                                 = MakeBeep(AudInfo.tf, AudInfo.beepLengthSecs, AudInfo.fs);
AudInfo.Beep                         = [beep; beep];
pahandle = PsychPortAudio('Open', our_device, [], [], [], 2); %open device
 
%% Make visual stimuli (gaussian blob)
screens = Screen('Screens');
screenNumber = max(screens);
black = BlackIndex(screenNumber);
opacity = 0.8;
PsychDebugWindowConfiguration([], opacity)

[windowPtr, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
[ScreenInfo.xaxis, ScreenInfo.yaxis] = Screen('WindowSize',windowPtr);
[center(1), center(2)]     = RectCenter(windowRect);
ScreenInfo.xmid            = center(1); % horizontal center
ScreenInfo.ymid            = center(2); % vertical center
ScreenInfo.numPixels_perCM = 6.2;
ScreenInfo.liftingYaxis    = 226;
ifi = Screen('GetFlipInterval', windowPtr);

%calculate visual angle
ExpInfo.sittingDistance              = 113.0;
ExpInfo.leftspeaker2center           = 65.5;
ExpInfo.rightspeaker2center          = 65.5;
ExpInfo.leftmostVisualAngle          = (180/pi) * atan(ExpInfo.leftspeaker2center / ...
                                       ExpInfo.sittingDistance);
ExpInfo.rightmostVisualAngle         = (180/pi) * atan(ExpInfo.leftspeaker2center / ...
                                       ExpInfo.sittingDistance);
                                   
% intensity of standard stimulus
VSinfo.scaling                       = 0.4; % a ratio between 0 to 1 to be multipled by 255
pblack                               = 1/8; % set contrast to 1*1/8 for the "black" background, so it's not too dark and the projector doesn't complain
% define the visual stimuli
VSinfo.Distance                      = linspace(-30,30,16); %in deg
VSinfo.numLocs                       = length(VSinfo.Distance);
VSinfo.numFrames                     = 6;
VSinfo.duration                      = VSinfo.numFrames * ifi;%s
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
                                   
                                   
%% test all speakers (present AV pairs)
left = 1:1:16;
right = 16:-1:1;
audTrain = [left; right];
for i=1:2
    for j=1:16
    %Calculate the coordinates of the target stimuli
        VSinfo.arrangedLocs_deg = VSinfo.Distance(audTrain(i,j));
        VSinfo.arrangedLocs_cm  = round(tan(deg2rad(VSinfo.arrangedLocs_deg)).*ExpInfo.sittingDistance,2);
        targetLoc = round(ScreenInfo.xmid + ScreenInfo.numPixels_perCM.*...
                    VSinfo.arrangedLocs_cm);
        %Make visual stimuli
        blob_coordinates = [targetLoc, ScreenInfo.liftingYaxis];    
        dotCloud = generateOneBlob(windowPtr,blob_coordinates,VSinfo,ScreenInfo);

        %----------------------------------------------------------------------
        %---------------------display audiovisual stimuli----------------------
        %----------------------------------------------------------------------

        %present the audiovisal single event pair    
        input_on = ['<',num2str(1),':',num2str(audTrain(i,j)),'>'];
        fprintf(Arduino,input_on);
        PsychPortAudio('FillBuffer',pahandle, AudInfo.Beep);
        PsychPortAudio('Start',pahandle,1,0,0);
            for kk = 1:VSinfo.numFrames 
                    Screen('DrawTexture',windowPtr,dotCloud,[],...
                        [0,0,ScreenInfo.xaxis,ScreenInfo.yaxis]);
                    Screen('Flip',windowPtr);
            end 
        WaitSecs(0.2)
        input_off = ['<',num2str(0),':',num2str(audTrain(i,j)),'>'];
        fprintf(Arduino,input_off);   
        PsychPortAudio('Stop',pahandle);
        WaitSecs(0.15)
    end 
    WaitSecs(0.5)
end

fclose(Arduino);
delete(Arduino)

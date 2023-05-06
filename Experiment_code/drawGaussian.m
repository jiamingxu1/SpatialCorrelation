sca;
close all;
clear;

PsychDefaultSetup(2);
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
ScreenInfo.backgroundColor = 105;
ScreenInfo.numPixels_perCM = 7.5;
ScreenInfo.liftingYaxis    = 300; 

ifi = Screen('GetFlipInterval', windowPtr);
% Screen('BlendFunction', windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% intensity of standard stimulus
    VSinfo.standard                      = 0.2; % a ratio between 0 to 1 to be multipled by 255
    pblack                               = 1/8; % set contrast to 1*1/8 for the "black" background, so it's not too dark and the projector doesn't complain
    % for some versions, the max RGB is 255, for some, the max RGB is 1, if
    % the RGB value you draw goes beyond the max, it draws weird stuff
    
% define the visual stimuli

    VSinfo.numFrames                     = 6;
    VSinfo.duration                      = VSinfo.numFrames * ifi;%s
    VSinfo.width                         = 401; %(pixel) Increasing this value will make the cloud more blurry (arbituary value)
    VSinfo.boxSize                       = 201; %This is the box size for each cloud (arbituary value)
    %set the parameters for the visual stimuli
    VSinfo.blackBackground               = pblack * ones(ScreenInfo.xaxis,ScreenInfo.yaxis);
    VSinfo.transCanvas                   = zeros(ScreenInfo.xaxis,ScreenInfo.yaxis);
    x                                    = 1:1:VSinfo.boxSize; y = x;
    VSinfo.x                             = x; VSinfo.y = y;
    [X,Y]                                = meshgrid(x,y);
    VSinfo.cloud1d                       = mvnpdf([X(:) Y(:)],[median(x) median(y)],...
    [VSinfo.width 0; 0 VSinfo.width]);
    pscale                               = (1-pblack)/max(VSinfo.cloud1d); % the max contrast of the blob adds the background contrast should <= 1
    VSinfo.cloud1d                         = VSinfo.cloud1d .* pscale;
    VSinfo.Cloud                         = VSinfo.standard.*reshape(VSinfo.cloud1d,length(x),length(y));
    VSinfo.blk_texture                   = Screen('MakeTexture', windowPtr, VSinfo.blackBackground,[],[],[],2);

% % Set the parameters for the visual stimulus
% VSinfo.numFrames        = 6;
% VSinfo.width            = 401; %(pixel) Increasing this value will make the cloud more blurry
% VSinfo.boxSize          = 201; %This is the box size for each cloud.
% VSinfo.intensity        = 10; %This determines the height of the clouds. Lowering this value will make
%                                 %them have lower contrast
% VSinfo.transparentCanvas = zeros(ScreenInfo.xaxis,ScreenInfo.yaxis);
% VSinfo.blackBackground = zeros(ScreenInfo.xaxis,ScreenInfo.yaxis);
% x                  = 1:1:VSinfo.boxSize; y = x;
% [X,Y]              = meshgrid(x,y);
% cloud              = 1e2.*mvnpdf([X(:) Y(:)],[median(x) median(y)],...
%                         [VSinfo.width 0; 0 VSinfo.width]);
% VSinfo.Cloud       = 255.*VSinfo.intensity.*reshape(cloud,length(x),length(y)); 
% VSinfo.blk_texture = Screen('MakeTexture', windowPtr, VSinfo.blackBackground,[],[],[],2);    

% Display visual stimuli
targetLoc = ScreenInfo.xmid;
blob_coordinates = [targetLoc, ScreenInfo.liftingYaxis];    
dotCloud = generateOneBlob(windowPtr,blob_coordinates,VSinfo,ScreenInfo);
 
for j = 1:VSinfo.numFrames %100ms  
        Screen('DrawTexture',windowPtr, dotCloud,[],[0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
        Screen('Flip',windowPtr);
end 
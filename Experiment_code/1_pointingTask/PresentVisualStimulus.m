%This function task the position of target visual stimulus, experiment
%information,screen information and generate response (in cm) measured 
%using the pointing device, response time, the locations of randomly drawn 
%dots, and RNG generators.
function [Response_deg, Response_pixel, RT] = PresentVisualStimulus(xLoc,...
    ScreenInfo, ExpInfo, windowPtr)    
    %----------------------------------------------------------------------
    %--------------------Display the target for 100 ms---------------------
    %----------------------------------------------------------------------
    yLoc = ScreenInfo.yaxis-ScreenInfo.liftingYaxis; %vertical
    %present the target for 100 ms
    for i = 1:ExpInfo.numFrames_target 
        Screen('DrawTexture',windowPtr, ScreenInfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
        Screen('DrawDots', windowPtr, [xLoc yLoc],8,[250 250 250]);
        Screen('Flip',windowPtr); 
        %Screen('AddFrameToMovie',windowPtr);
    end
    
    %blank screen for 0.1 seconds
    Screen('DrawTexture',windowPtr, ScreenInfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
    Screen('Flip',windowPtr);
    WaitSecs(0.1);

    %----------------------------------------------------------------------
    %---------------------Display the visual feedback----------------------
    %----------------------------------------------------------------------
    SetMouse(randi(ScreenInfo.xmid*2,1), ScreenInfo.ymid*2, windowPtr);
    buttons = 0;
    tic
    while sum(buttons)==0
        [x,y,buttons] = GetMouse(windowPtr); HideCursor(windowPtr);
        x = min(x, ScreenInfo.xmid*2); x = max(0,x);
        y = ScreenInfo.ymid*2;
        Screen('DrawTexture',windowPtr, ScreenInfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
        Screen('FillRect', windowPtr, [0 300 0],[x-3 yLoc-24 x+3 yLoc-12]);
        Screen('FillPoly', windowPtr, [0 300 0],[x-3 yLoc-12; x yLoc; x+3 yLoc-12]);
        Screen('Flip',windowPtr,0,0);
    end
    HideCursor;
    Response_pixel = x;
    Response_cm    = (Response_pixel -  ScreenInfo.xmid)/ScreenInfo.numPixels_perCM;
    Response_deg   = rad2deg(atan(Response_cm/105));
    RT             = toc;
    
    %blank screen for 1 seconds
    Screen('DrawTexture',windowPtr, ScreenInfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
    Screen('Flip',windowPtr);
    WaitSecs(1); HideCursor;
end   

    
    
    
    
    
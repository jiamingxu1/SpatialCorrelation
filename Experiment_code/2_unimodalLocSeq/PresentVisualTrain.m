%This function displays visual train and records localization responses 
%(in degree) measured using the pointing device, response time
function [Response_deg, RT] = PresentVisualTrain(~,VTrialNum,ExpInfo,...
    ScreenInfo,VSinfo,windowPtr)   
  
    Vtrain = cell2mat(VSinfo.randSampleVtrain(VTrialNum));

        
    % fixation
    Screen('DrawTexture',windowPtr,VSinfo.blk_texture,[],...
        [0,0,ScreenInfo.xaxis,ScreenInfo.yaxis]);
    Screen('FillRect', windowPtr,[255 0 0], [ScreenInfo.x1_lb,...
        ScreenInfo.y1_lb, ScreenInfo.x1_ub, ScreenInfo.y1_ub]);
    Screen('FillRect', windowPtr,[255 0 0], [ScreenInfo.x2_lb,...
        ScreenInfo.y2_lb, ScreenInfo.x2_ub, ScreenInfo.y2_ub]);
    Screen('Flip',windowPtr); WaitSecs(1);

    % blank screen
    Screen('DrawTexture',windowPtr,VSinfo.blk_texture,[],...
        [0,0,ScreenInfo.xaxis,ScreenInfo.yaxis]);
    Screen('Flip',windowPtr);
    WaitSecs(0.5);
    
    %----------------------------------------------------------------------
    %---------------------Display visual train-----------------------------
    %----------------------------------------------------------------------
        
    for s = 1:length(Vtrain)
        
        %Calculate the coordinates of the target stimuli
        VSinfo.arrangedLocs_deg = ExpInfo.stimLocs(Vtrain(s));
        VSinfo.arrangedLocs_cm  = round(tan(deg2rad(VSinfo.arrangedLocs_deg)).*...
            ExpInfo.sittingDistance,2);
        targetLoc = round(ScreenInfo.xmid + ScreenInfo.numPixels_perCM.*...
                    VSinfo.arrangedLocs_cm);
                
        %Make visual stimuli
        blob_coordinates = [targetLoc; ScreenInfo.liftingYaxis];    
        dotCloud = generateOneBlob(windowPtr,blob_coordinates,VSinfo,ScreenInfo);
        
        for kk = 1:VSinfo.numFrames 
            Screen('DrawTexture',windowPtr,dotCloud,[],...
                [0,0,ScreenInfo.xaxis,ScreenInfo.yaxis]);
            Screen('Flip',windowPtr);
        end
        
        for k = 1:6 %200ms blank screen
            Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
            Screen('Flip',windowPtr);
        end
         
    end
    
    % black screen for 0.1 seconds
    Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
    Screen('Flip',windowPtr);
    WaitSecs(0.1);
    
    %----------------------------------------------------------------------
    %--------------Record response using the pointing device---------------
    %----------------------------------------------------------------------
    yLoc = ScreenInfo.yaxis-ScreenInfo.liftingYaxis;
    SetMouse(randi(ScreenInfo.xmid*2,1), ScreenInfo.ymid*2, windowPtr);
    buttons = 0;
    tic
    while sum(buttons)==0
        [x,~,buttons] = GetMouse(windowPtr); HideCursor;
        x = min(x, ScreenInfo.xmid*2); x = max(0,x);
        Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
        Screen('FillRect', windowPtr, [0 300 0],[x-3 yLoc-24 x+3 yLoc-12]);
        Screen('FillPoly', windowPtr, [0 300 0],[x-3 yLoc-12; x yLoc; x+3 yLoc-12]);
        Screen('Flip',windowPtr,0,0);
    end
    HideCursor;
    Response_pixel = x;
    Response_cm    = (Response_pixel -  ScreenInfo.xmid)/ScreenInfo.numPixels_perCM;
    Response_deg   = rad2deg(atan(Response_cm/ExpInfo.sittingDistance));
    RT             = toc;
    %blank screen for 0.5 seconds
    Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
    Screen('Flip',windowPtr);
    WaitSecs(0.5); HideCursor;
 
end
    
    
    
    
    
function [localization, RT1, unity, RT2] = PresentAVtrains(TrialNum,...
    ExpInfo,ScreenInfo,VSinfo,AudInfo,Arduino,pahandle,windowPtr)
   
    Atrain = cell2mat(ExpInfo.randSampleAVtrain(1,TrialNum));
    Vtrain = cell2mat(ExpInfo.randSampleAVtrain(2,TrialNum));
    
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
    %---------------------Display multisensory train-----------------------
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

        %Display 
        if rem(Atrain(s),2) == 1 %turn on one speaker, full volume
            %present the audiovisal single event pair    
            input_on = ['<',num2str(1),':',num2str((Atrain(s)+1)/2),'>'];
            fprintf(Arduino,input_on);
            PsychPortAudio('FillBuffer',pahandle, AudInfo.GaussianWhiteNoise);
            Screen('DrawTexture',windowPtr,dotCloud,[],...
                            [0,0,ScreenInfo.xaxis,ScreenInfo.yaxis]);
            Screen('Flip',windowPtr);
            PsychPortAudio('Start',pahandle,1,0,0);
            WaitSecs(0.1)
            Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                        [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
            Screen('Flip',windowPtr);
            input_off = ['<',num2str(0),':',num2str((Atrain(s)+1)/2),'>'];
            fprintf(Arduino,input_off);   
            PsychPortAudio('Stop',pahandle);
            WaitSecs(0.1)
        
        else %play sound in-between two speakers, half volume
            %present the audiovisal single event pair    
            input_on = ['<',num2str(1),':',num2str(Atrain(s)/2),',',...
                num2str(Atrain(s)/2+1),'>'];
            fprintf(Arduino,input_on);
            PsychPortAudio('FillBuffer',pahandle, AudInfo.inBetweenGWN);
            Screen('DrawTexture',windowPtr,dotCloud,[],...
                            [0,0,ScreenInfo.xaxis,ScreenInfo.yaxis]);
            Screen('Flip',windowPtr);
            PsychPortAudio('Start',pahandle,1,0,0);
            WaitSecs(0.1)
            Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                        [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
            Screen('Flip',windowPtr);
            input_off = ['<',num2str(0),':',num2str(Atrain(s)/2),',',...
                num2str(Atrain(s)/2+1),'>'];
            fprintf(Arduino,input_off);   
            PsychPortAudio('Stop',pahandle);
            WaitSecs(0.1)
        end
    end     

    %----------------------------------------------------------------------
    %--------------Record response using the pointing device---------------
    %----------------------------------------------------------------------
    Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                        [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
    Screen('Flip',windowPtr); WaitSecs(0.5);
    yLoc = ScreenInfo.yaxis-ScreenInfo.liftingYaxis;
    Screen('TextSize', windowPtr, 12); 
    HideCursor(1);
    SetMouse(randi(ScreenInfo.xmid*2,1), ScreenInfo.ymid*2,1)
    buttons = zeros(1,16); tic
    %localize the stimulus using a visual cursor
    while buttons(1) == 0
        [x,y,buttons] = GetMouse(1);
         x = min(x, ScreenInfo.xmid*2); x = max(0,x);
         y = ScreenInfo.ymid*2;
         HideCursor(1);
        Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
        if ExpInfo.order_VSnAS(TrialNum) == 1 %A trial
            Screen('FillRect', windowPtr, ScreenInfo.cursorColorA,...
                [x-3 yLoc-24 x+3 yLoc-12]);
            Screen('FillPoly', windowPtr, ScreenInfo.cursorColorA,...
                [x-3 yLoc-12; x yLoc; x+3 yLoc-12]);
            Screen('DrawText', windowPtr, ScreenInfo.dispModalityA,...
                x-5, yLoc-30,[255,255,255]);
            Screen('Flip',windowPtr);
        else                                  %V trial
            Screen('FillRect', windowPtr, ScreenInfo.cursorColorV,...
                [x-3 yLoc-24 x+3 yLoc-12]);
            Screen('FillPoly', windowPtr, ScreenInfo.cursorColorV,...
                [x-3 yLoc-12; x yLoc; x+3 yLoc-12]);
            Screen('DrawText', windowPtr, ScreenInfo.dispModalityV,...
                x-5, yLoc-30,[255,255,255]);
            Screen('Flip',windowPtr);
        end
        
    end
    RT1            = toc;
    Response_pixel = x;
    Response_cm    = (Response_pixel - ScreenInfo.xmid)/ScreenInfo.numPixels_perCM;
    localization   = (180/pi)*(atan(Response_cm/ExpInfo.sittingDistance));
    Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
    Screen('Flip',windowPtr); WaitSecs(0.1);
    HideCursor;
    %Unity judgment
    if ExpInfo.bool_unityReport(TrialNum) == 1
        Screen('TextSize', windowPtr, 25);
        click = 0; tic
        while click == 0
            Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
            Screen('FillRect', windowPtr, [0,0,0],[x-3 yLoc-100 x+3 yLoc-100]);
            Screen('DrawText', windowPtr, 'C=1    OR    C=2',ScreenInfo.xmid-87.5,...
                yLoc-10,[255 255 255]);
            Screen('Flip',windowPtr);
            %click left button: C=1; click right button: C=2
            [click,~,~,unity] = GetClicks;
        end
        RT2     = toc; HideCursor(windowPtr);
        %show a white frame to confirm the choice
        x_shift = ScreenInfo.x_box_unity(unity,:);
        Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
        Screen('DrawText', windowPtr, 'C=1    OR    C=2',ScreenInfo.xmid-87.5,...
                yLoc-10,[255 255 255]);
        Screen('FrameRect', windowPtr, [255,255,255], [ScreenInfo.xmid+x_shift(1),...
            yLoc-10+ScreenInfo.y_box_unity(1), ScreenInfo.xmid+x_shift(2),...
            yLoc-10+ScreenInfo.y_box_unity(2)]);
        Screen('Flip',windowPtr); WaitSecs(0.1);
        Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
        Screen('Flip',windowPtr); WaitSecs(0.1);
    else
        unity = NaN; RT2 = NaN; 
    end
    HideCursor(windowPtr);
end
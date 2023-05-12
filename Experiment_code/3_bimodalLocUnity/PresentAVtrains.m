function [localization, RT1, unity, RT2] = PresentAVtrains(TrialNum,...
    nEvents,ExpInfo,ScreenInfo,VSinfo,AudInfo,Arduino,pahandle,windowPtr)
   
    %show fixation cross for 0.1 s and then a blank screen for 0.5 s
        Screen('FillRect', windowPtr,[255 255 255], [ScreenInfo.x1_lb,...
            ScreenInfo.y1_lb, ScreenInfo.x1_ub, ScreenInfo.y1_ub]);
        Screen('FillRect', windowPtr,[255 255 255], [ScreenInfo.x2_lb,...
            ScreenInfo.y2_lb, ScreenInfo.x2_ub, ScreenInfo.y2_ub]);
        Screen('Flip',windowPtr); WaitSecs(0.5);
        Screen('Flip',windowPtr); WaitSecs(0.5);

    for s = 1:nEvents % single events
        %Calculate the coordinates of the target stimuli
        VSinfo.arrangedLocs_deg = VSinfo.Distance(ExpInfo.Vtrain{TrialNum}(s));
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
        input_on = ['<',num2str(1),':',num2str(ExpInfo.Atrain{TrialNum}(s)),'>'];
        fprintf(Arduino,input_on);
        PsychPortAudio('FillBuffer',pahandle, AudInfo.Beep);
        PsychPortAudio('Start',pahandle,1,0,0);
            for kk = 1:VSinfo.numFrames 
                    Screen('DrawTexture',windowPtr,dotCloud,[],...
                        [0,0,ScreenInfo.xaxis,ScreenInfo.yaxis]);
                    Screen('Flip',windowPtr);
            end 
        WaitSecs(0.2)
        input_off = ['<',num2str(0),':',num2str(ExpInfo.Atrain{TrialNum}(s)),'>'];
        fprintf(Arduino,input_off);   
        PsychPortAudio('Stop',pahandle);
        WaitSecs(0.15)
    end     

    %----------------------------------------------------------------------
    %--------------Record response using the pointing device---------------
    %----------------------------------------------------------------------
    Screen('Flip',windowPtr); WaitSecs(0.5);
    yLoc = ScreenInfo.yaxis-ScreenInfo.liftingYaxis;
    Screen('TextSize', windowPtr, 12);
    SetMouse(randi(ScreenInfo.xmid*2,1), yLoc, windowPtr); 
    buttons = zeros(1,16); tic
    %localize the stimulus using a visual cursor
    while buttons(1) == 0
        [x,~,buttons] = GetMouse; HideCursor;
        Screen('FillRect', windowPtr, ScreenInfo.cursorColor,...
            [x-3 yLoc-24 x+3 yLoc-12]);
        Screen('FillPoly', windowPtr, ScreenInfo.cursorColor,...
            [x-3 yLoc-12; x yLoc; x+3 yLoc-12]);
        Screen('DrawText', windowPtr, ScreenInfo.dispModality,...
            x-5, yLoc-30,[255 255 255]);
        Screen('Flip',windowPtr);
    end
    RT1            = toc;
    Response_pixel = x;
    Response_cm    = (Response_pixel - ScreenInfo.xmid)/ScreenInfo.numPixels_perCM;
    localization   = (180/pi)*(atan(Response_cm/ExpInfo.sittingDistance));
    Screen('Flip',windowPtr); WaitSecs(0.1);
    
    %Unity judgment
    if ExpInfo.bool_unityReport(TrialNum) == 1
        Screen('TextSize', windowPtr, 25);
        click = 0; tic
        while click == 0
            Screen('FillRect', windowPtr, [0,0,0],[x-3 yLoc-100 x+3 yLoc-100]);
            Screen('DrawText', windowPtr, 'C=1    OR    C=2',ScreenInfo.xmid-87.5,...
                yLoc-10,[255 255 255]);
            Screen('Flip',windowPtr);
            %click left button: C=1; click right button: C=2
            [click,~,~,unity] = GetClicks;
        end
        RT2     = toc;
        %show a white frame to confirm the choice
        x_shift = ScreenInfo.x_box_unity(unity,:);
        Screen('DrawText', windowPtr, 'C=1    OR    C=2',ScreenInfo.xmid-87.5,...
                yLoc-10,[255 255 255]);
        Screen('FrameRect', windowPtr, [255,255,255], [ScreenInfo.xmid+x_shift(1),...
            yLoc-10+ScreenInfo.y_box_unity(1), ScreenInfo.xmid+x_shift(2),...
            yLoc-10+ScreenInfo.y_box_unity(2)]);
        Screen('Flip',windowPtr); WaitSecs(0.1);
        Screen('Flip',windowPtr); WaitSecs(0.1);
    else
        unity = NaN; RT2 = NaN; 
    end
    
end
%This function displays auditory train and records localization responses 
%(in degree) measured using the pointing device, response time
function [Response_deg, RT]=PresentAuditoryTrain(~,ATrialNum,ExpInfo,...
    ScreenInfo,AudInfo,VSinfo,Arduino,pahandle,windowPtr)
   
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
    %---------------------display auditory train---------------------------
    %----------------------------------------------------------------------
    Atrain = cell2mat(AudInfo.randSampleAtrain(ATrialNum));
    for s = 1:length(Atrain)
        if rem(Atrain(s),2) == 1 %turn on one speaker, full volume
            %present the audiovisal single event pair    
            input_on = ['<',num2str(1),':',num2str((Atrain(s)+1)/2),'>'];
            fprintf(Arduino,input_on);
            PsychPortAudio('FillBuffer',pahandle, AudInfo.GaussianWhiteNoise);
            PsychPortAudio('Start',pahandle,1,0,0);
            WaitSecs(0.1)
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
            PsychPortAudio('Start',pahandle,1,0,0);
            WaitSecs(0.1)
            input_off = ['<',num2str(0),':',num2str(Atrain(s)/2),',',...
                num2str(Atrain(s)/2+1),'>'];
            fprintf(Arduino,input_off);   
            PsychPortAudio('Stop',pahandle);
            WaitSecs(0.1)
        end
            
    end 
          
%   black screen for 0.1 seconds
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
    
   
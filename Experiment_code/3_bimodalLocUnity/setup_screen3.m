function  ScreenInfo = setup_screen3(display)

switch display
    case 1 % testing room
        Screen('Preference', 'SkipSyncTests', 1);
        [ScreenInfo.windowPtr,rect] = Screen('OpenWindow', 0, [5,5,5]);
        [ScreenInfo.xaxis, ScreenInfo.yaxis] = Screen('WindowSize',ScreenInfo.windowPtr);
    
    case 2 % my laptop
        [ScreenInfo.windowPtr,rect] = Screen('OpenWindow', 0, [5,5,5],[100 100 1000 600]); % for testing
        [ScreenInfo.xaxis, ScreenInfo.yaxis] = Screen('WindowSize',ScreenInfo.windowPtr);
       
end
        Screen('Preference', 'VisualDebugLevel', 1);
%         Screen('Preference', 'SkipSyncTests', 1);
      
        Screen('TextSize', ScreenInfo.windowPtr, 35) ;   
        Screen('TextFont',ScreenInfo.windowPtr,'Times');
        Screen('TextStyle',ScreenInfo.windowPtr,1); 

        [center(1), center(2)]     = RectCenter(rect);
        ScreenInfo.numPixels_perCM = 7.5;
        ScreenInfo.xmid            = center(1); % horizontal center
        ScreenInfo.ymid            = center(2); % vertical center
        ScreenInfo.backgroundColor = 0;
        ScreenInfo.liftingYaxis    = 304.25; % speaker center height
        ScreenInfo.cursorColor     = [0,0,255]; %A: blue, V:red
        ScreenInfo.dispModality    = 'A'; %always localize the auditory component

        %fixation locations
        ScreenInfo.x1_lb = ScreenInfo.xmid-7; ScreenInfo.x2_lb = ScreenInfo.xmid-1;
        ScreenInfo.x1_ub = ScreenInfo.xmid+7; ScreenInfo.x2_ub = ScreenInfo.xmid+1;
        ScreenInfo.y1_lb = ScreenInfo.yaxis-ScreenInfo.liftingYaxis-1;
        ScreenInfo.y1_ub = ScreenInfo.yaxis-ScreenInfo.liftingYaxis+1;
        ScreenInfo.y2_lb = ScreenInfo.yaxis-ScreenInfo.liftingYaxis-7;
        ScreenInfo.y2_ub = ScreenInfo.yaxis-ScreenInfo.liftingYaxis+7;

end


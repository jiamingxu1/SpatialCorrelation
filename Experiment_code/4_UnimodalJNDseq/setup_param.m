function ExpInfo = setup_param(display)


ExpInfo.nRep = 3;

         
switch display
    case 1 % meyer 957 
     addpath(genpath('/e/3.3/p3/hong/Desktop/Project5/Psychtoolbox/'));
     ExpInfo.sittingDistance = 105;
     
    case 2 % my laptop
       ExpInfo.sittingDistance = 105;
end
    
    % set up exp. design 
    ExpInfo.totalLoc = 16;
    ExpInfo.window   = 9;
    ExpInfo.nWindow  = 8;
    ExpInfo.nEvents  = 5;
    ExpInfo.nRep     = 10;
    ExpInfo.nTrial = ExpInfo.nRep*ExpInfo.nWindow;
    
    % save responses
    ExpInfo.result = zeros(ExpInfo.nTrial,2); % trial by [actual location; response location]
    
end

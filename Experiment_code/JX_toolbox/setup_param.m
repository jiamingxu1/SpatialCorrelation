function ExpInfo = setup_param(display)


ExpInfo.nRep = 3;

      
        
switch display
    case 1 % meyer 957 
     addpath(genpath('/e/3.3/p3/hong/Desktop/Project5/Psychtoolbox/'));
     
    case 2 % my laptop
      
end
    
    % set up exp. design 
    ExpInfo.sittingDistance = 105;
    ExpInfo.nAudFile = 21;
    ExpInfo.repetitions = 1; % how many times for each aud location
    ExpInfo.actualAud = linspace(-18,18,21);
    ExpInfo.nTrial = ExpInfo.nRep*ExpInfo.nAudFile;
    ExpInfo.design = repelem(1:ExpInfo.nAudFile,1,ExpInfo.nRep)';
    ExpInfo.design = ExpInfo.design(randperm(numel(ExpInfo.design),numel(ExpInfo.design)));

    % save responses
    ExpInfo.result = zeros(ExpInfo.nTrial,2); % trial by [actual location; response location]
    
end

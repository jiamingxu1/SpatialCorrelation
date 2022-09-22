function ExpInfo = setup_param(display)

switch display
    case 1 % meyer 957 
        ExpInfo.nRep = 20;
        ExpInfo.fileOrder = [10:-1:1,11:20];
        ExpInfo.fileDir = '/Users/oliviaxujiaming/Desktop/NYU_research/Project_2/Experiment code/Auditory recording/Pilot/JX';

    case 2 % my laptop
        ExpInfo.nRep = 1;
        ExpInfo.fileOrder = (1:21);
        ExpInfo.fileDir = '/Users/oliviaxujiaming/Desktop/NYU_research/Project_2/Experiment code/Auditory recording/Pilot/JX/*.wav';
end
    ExpInfo.sittingDistance = 105;
    
    % set up exp. design 
    ExpInfo.nAudFile = 21;
    ExpInfo.repetitions = 1; % how many times for each aud location
    ExpInfo.actualAud = linspace(-18,18,21);
    ExpInfo.nTrial = ExpInfo.nRep*ExpInfo.nAudFile;
    ExpInfo.design = repelem(1:ExpInfo.nAudFile,1,ExpInfo.nRep)';
    %ExpInfo.design = ExpInfo.design(randperm(numel(ExpInfo.design),numel(ExpInfo.design)));

    % save responses
    ExpInfo.result = zeros(ExpInfo.nTrial,2); % trial by [actual location; response location]
    
end

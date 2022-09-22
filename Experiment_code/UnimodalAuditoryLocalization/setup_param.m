function ExpInfo = setup_param(display)

ExpInfo.fileName = cell(21,1);
switch display
    case 1 % meyer 957 
        ExpInfo.nRep = 20;
        for iF = 1:21
            tmpPath =  dir([fullfile(pwd, '../AuditoryRecording/Pilot/JX/'),num2str(iF),'_*']);
            ExpInfo.fileName{iF,1} = [tmpPath.folder '/' tmpPath.name];
        end
        
    case 2 % my laptop
        ExpInfo.nRep = 1;
        
        for iF = 1:21
            tmpPath =  dir([fullfile(pwd, '../AuditoryRecording/Pilot/JX/'),num2str(iF),'_*']);
            ExpInfo.fileName{iF,1} = [tmpPath.folder '/' tmpPath.name];
        end
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

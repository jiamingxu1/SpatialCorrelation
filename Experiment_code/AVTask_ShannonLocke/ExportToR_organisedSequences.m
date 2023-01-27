all_init = {'EN','GK','HL','RD','SL','JZ','PS','MR','EG','DB'}; % ,'MS'};
sIDs = [124 139 876 369 773 308 595 940 929 429]; % ,552];

% Empty vectors for storing all data to be saved:
PF = [];
sID = [];
session = [];
modality = [];
duration = [];
stimLvl = [];
response = []; 

idx = 0;
for ii = 1:length(all_init) % EACH SUBJECT
    for jj = 1:4 % EACH SESSION
        
        % File name:
        fileNameString = [all_init{ii} '_AVTemporalTask_rateJND_V5_final_S' num2str(jj)];
        dataPath = ['data_AVTemporalTask_rateJND_V5/' all_init{ii} '/'];
        allMatchedFiles = dir([dataPath fileNameString '*']);
        try
            % load file:
            allMatchedFiles = allMatchedFiles.name;
            load([dataPath allMatchedFiles]);
            
            % Create vectors for stim levels and responses:
            Vx = visUML.x;
            Ax = audUML.x;
            Mx = multUML.x;
            Vr = visUML.r;
            Ar = audUML.r;
            Mr = multUML.r;
        
            % Get stimulus levels and responses to match trial sequence:
            mod_by_trial = exp.designMat(:,2); % which modality
            stim_lvl = NaN(600,1); % vector to store stimulus levels
            resp = NaN(600,1); % vector to store responses
            for kk = 1:600
                mm = mod_by_trial(kk);
                switch mm
                    case 1 % visual
                        stim_lvl(kk) = Vx(1);
                        resp(kk) = Vr(1);
                        Vx(1) = [];
                        Vr(1) = [];
                    case 2 % auditory
                        stim_lvl(kk) = Ax(1);
                        resp(kk) = Ar(1);
                        Ax(1) = [];
                        Ar(1) = [];
                    case 3 % multisensory
                        stim_lvl(kk) = Mx(1);
                        resp(kk) = Mr(1);
                        Mx(1) = [];
                        Mr(1) = [];
                end
            end
        
        % Store results:
        sID = [sID; repmat(sIDs(ii),600,1)];
        session = [session; repmat(jj,600,1)];
        modality = [modality; exp.designMat(:,2)];
        duration = [duration; exp.designMat(:,3)];
        stimLvl = [stimLvl; stim_lvl];
        response = [response; resp];
        
        % Update counter:
        idx = idx + 1;
        
        catch
            fprintf('\n\n Selected file could not be loaded!\n\n');
            disp(allMatchedFiles)
        end
        
    end
end

% Number the PFs:
PF = repmat(1:3*idx, 200,1);
PF = PF(:);

% Get rate: Comparison - Standard:
stimLvl = stimLvl - 8;

% Save to file:
T = table(PF,sID,session,modality,duration,stimLvl,response);
filesave = '/Users/shannonlocke/GoogleDrive/Library/Experiments/AudiovisualRateDiscrimination/DataAnalysis/RateJNDinR/data_raw_rateJND/rateJNDorgdata.txt';
writetable(T,filesave,'Delimiter',' ')
% Reverse correlation analysis:

set(0,'DefaultFigureWindowStyle','docked')
all_init = {'EN','GK','HL','RD','SL','JZ','PS','MR','EG','DB'};
sIDs = [124 139 876 369 773 308 595 940 929 429];
fs = 60; % sampling frequency

% Storage vectors:
all_r_1s = {};
all_r_2s = {};
sigDiffs =[];

for ii = 1:length(all_init) % EACH SUBJECT
    
    % Empty vectors:
    sID = [];
    session = [];
    rate = [];
    tempConflictYN = [];
    minOffset = [];
    maxOffset = [];
    propSync = [];
    sumShiftsReq = [];
    meanShiftsReq = [];
    response = [];
    V = [];
    A = [];
    r_1s = [];
    r_2s = [];
    m_1s = [];
    m_2s = [];
    all_xcorr = [];
    all_MCD_corr = [];
    
    % Get Data:
    for jj = 1:2 % EACH SESSION
        % Find files:
        fileNameString = [all_init{ii} '_AVTemporalTask_controlExp_randomSeq_S' num2str(jj)];
        dataPath = ['data_AVTemporalTask_controlExp/' all_init{ii} '/'];
        allMatchedFiles = dir([dataPath fileNameString '*']);
        try
            % Load file:
            allMatchedFiles = allMatchedFiles.name;
            load([dataPath allMatchedFiles]);
            % Store info:
            sID = [sID; repmat(sIDs(ii),size(resMat,1),1)];
            session = [session; repmat(jj,size(resMat,1),1)];
            rate = [rate; resMat(:,1)];
            tempConflictYN = [tempConflictYN; resMat(:,2)];
            maxOffset = [maxOffset; resMat(:,3)];
            propSync = [propSync; resMat(:,4)];
            response = [response; resMat(:,5)];
            % Get sequences:
            V = [V all_frameType];
            A = [A all_ear];
        catch
            fprintf('\n\n Selected file could not be loaded!\n\n');
            disp(allMatchedFiles)
        end
    end
    
    % Prep data for cross-correlations:
    if size(V,2) == 0
        break % exit for loop if subject has no data!
    end
    V = V(:,tempConflictYN==1);
    A = A(:,tempConflictYN==1);
    resp = response(tempConflictYN==1);
    
    % Get individual cross-correlations:
    for kk = 1:size(V,2) % EACH TRIAL (temporal conflict only)
        ts2 = V(:,kk); % sequence of flashes on trial ii
        ts1 = A(:,kk); % sequence of clicks on trial ii
        [r,lag] = slidingCrossCorrelationCoefficient(ts2,ts1,60); % xcorr(ts2,ts1,'coeff'); % Compute CCG using mean subtract, sd divide normalisation
        %         [r,lag] = xcorr(ts2,ts1,'coeff'); % Compute CCG using coef method
        lag = lag/fs; % Convert from frames to time
        if resp(kk) == 1 % Common source
            r_1s = [r_1s r];
        else % Separate sources
            r_2s = [r_2s r];
        end
    end
        
        % Compute classification image:
        ccg_1s = mean(r_1s,2);
        ccg_2s = mean(r_2s,2);
        ccg_diff = ccg_1s - ccg_2s;
        smoothingKernal = gausswin(25);
        smoothingKernal = smoothingKernal / sum(smoothingKernal);
        filt_ccg_diff = conv(ccg_diff, smoothingKernal, 'same');
        
        % Permutation test (switch response labels):
        r_all = [r_1s r_2s];
        N = size(r_all,2);
        sims = 10000;
        nCommon  =sum(resp);
        all_simVals = nan(size(r_all,1),sims);
        for s = 1:sims % EACH SIMULATION
            idx = ShuffleRC(1:N,2);
            r_1s = r_all(:,idx(1:nCommon));
            r_2s = r_all(:,idx(nCommon+1:end));
            ccg_1s = mean(r_1s,2);
            ccg_2s = mean(r_2s,2);
            ccg_diff = ccg_1s - ccg_2s;
            simVals = conv(ccg_diff, smoothingKernal, 'same');
            all_simVals(:,s) = simVals;
        end
        perm_mean = mean(all_simVals');
        perm_lCI = quantile(all_simVals,0.025,2);
        perm_uCI = quantile(all_simVals,0.975,2);
        
        % Store significant portions:
        idx = (filt_ccg_diff < perm_uCI) & (filt_ccg_diff > perm_lCI);
        keepSig = filt_ccg_diff;
        keepSig(idx) = 0;
        sigDiffs = [sigDiffs keepSig];
        
%         % Plot mean CCGs:
%         figure; hold on;
%         title(['Subject: ' num2str(sIDs(ii))]);
%         xlabel('Lag (sec) ==> (-ve = V 1st,  +ve = A 1st)');
%         ylabel('Diff in xcorr');
%         xlim([-2 2]);
%         plot(lag,ccg_1s,'b');
%         plot(lag,ccg_2s, 'r');
%         plot(lag,mean([r_1s, r_2s],2),'k')
        
%         % Plot raw and smoothed classification image:
%         figure; hold on;
%         title(['Subject: ' num2str(sIDs(ii))]);
%         xlabel('Lag (sec) ==> (-ve = V 1st,  +ve = A 1st)');
%         ylabel('Diff in xcorr');
%         xlim([-2 2]);
%         ylim([-0.02 0.06]);
%         plot(lag,ccg_diff,'k');
%         plot(lag,filt_ccg_diff,'r')

        % Mega summary plot of the gods:
    runPartScript = 1;
    if runPartScript == 1
        figure; hold on;
        title(['Subject: ' num2str(sIDs(ii))]);
        xlabel('Light first < ------------- Lag (sec) ------------- > Sound first');
        ylabel('Diff in xcorr');
        xlim([-2 2]);
        % ylim([-0.02 0.06]);
        plot(lag,perm_mean,'k')
        plot(lag,perm_lCI, 'color', [0.5 0.5 0.5])
        plot(lag,perm_uCI, 'color', [0.5 0.5 0.5])
        plot(lag,filt_ccg_diff,'r')
        legend('perm. test','95% CI','95% CI','measured')
    end
    
    % Save data for example subject plot:
    exampleSubject = 139;
    runPartScript = 0;
    if (sIDs(ii) == exampleSubject) && (runPartScript == 1)
        dataPath = '/Users/shannonlocke/GoogleDrive/Library/PosterRepository/posterCRCNS2016/figures/';
        descriptors = {'xcorr','exampleSubject'};
        extension = '.txt';
        saveFile = createSaveFileName(descriptors,dataPath,extension);
        x = lag';
        y = filt_ccg_diff;
        perm = perm_mean';
        lCI = perm_lCI;
        uCI = perm_uCI;
        T = table(x,y,perm,lCI,uCI);
        writetable(T,saveFile,'Delimiter',' ')
    end     
        
end

% Store each subject's significant results:
descriptors = {'xcorr','all'};
extension = '.txt';
saveFile = createSaveFileName(descriptors,dataPath,extension);
[i1,j1] = find(sigDiffs > 0);
k1 = find(sigDiffs > 0);
[i2,j2] = find(sigDiffs < 0);
k2 = find(sigDiffs < 0);
x = lag([i1' i2'])';
y = [j1; j2];
z = sigDiffs([k1' k2'])';
T = table(x,y,z);
writetable(T,saveFile,'Delimiter',' ')
disp(T)

% Save processed data locally:
dataPath = '';
descriptors = {'classificationImageData'};
saveFile = createSaveFileName(descriptors,dataPath);
save(saveFile,'r_1s','r_2s')

% http://www.mathworks.com/matlabcentral/answers/5275-algorithm-for-coeff-scaling-of-xcorr
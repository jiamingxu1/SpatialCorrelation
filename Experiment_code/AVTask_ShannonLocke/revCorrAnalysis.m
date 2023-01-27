% Reverse correlation analysis:

set(0,'DefaultFigureWindowStyle','docked')
all_init = {'EN','GK','HL','RD','SL','JZ','MS','PS','MR','EG','DB'};
sIDs = [124 139 876 369 773 308 552 595 940 929 429];
fs = 60; % sampling frequency
nSamplesPadding = 7*fs; % 119; % length of padding in seconds

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
    
    for jj = 1:2 % EACH SESSION
        
        % Find and load file:
        fileNameString = [all_init{ii} '_AVTemporalTask_controlExp_randomSeq_S' num2str(jj)];
        dataPath = ['data_AVTemporalTask_controlExp/' all_init{ii} '/'];
        allMatchedFiles = dir([dataPath fileNameString '*']);
        try
            allMatchedFiles = allMatchedFiles.name;
            load([dataPath allMatchedFiles]);
            
            %             for kk = 1:size(all_ear,2)
            %                 [~,mo(kk),~] = get_maxOffset(all_frameType(:,kk),all_ear(:,kk),60);
            %                 [ssr(kk),msr(kk)] = get_seqSimilarity(all_frameType(:,kk),all_ear(:,kk),60);
            %             end
            
            % Store results:
            % -------------- %
            
            sID = [sID; repmat(sIDs(ii),size(resMat,1),1)];
            session = [session; repmat(jj,size(resMat,1),1)];
            rate = [rate; resMat(:,1)];
            tempConflictYN = [tempConflictYN; resMat(:,2)];
            maxOffset = [maxOffset; resMat(:,3)];
            %             minOffset = [minOffset; mo'];
            propSync = [propSync; resMat(:,4)];
            %             sumShiftsReq = [sumShiftsReq; ssr'];
            %             meanShiftsReq = [meanShiftsReq; msr'];
            response = [response; resMat(:,5)];
            
            V = [V all_frameType];
            A = [A all_ear];
            
        catch
            fprintf('\n\n Selected file could not be loaded!\n\n');
            disp(allMatchedFiles)
        end
        
    end
    
    if size(V) ~= 0
        
        for i = 1:size(V,2) % EACH TRIAL
            if tempConflictYN(i) == 1 % Only analyse sequences with conflict
                if rate(i) > 0 % Switch this to rate...
                    ts2 = V(:,i); % sequence of flashes on trial i
                    ts1 = A(:,i); % sequence of clicks on trial i
                    [r,lag] = slidingCrossCorrelationCoefficient(ts2,ts1,0); % xcorr(ts2,ts1,'coeff'); % Compute CCG
                    [MCD_corr, ~, MCD_output_signals] = MCD([zeros(1,nSamplesPadding) ts2' zeros(1,nSamplesPadding); zeros(1,nSamplesPadding) ts1' zeros(1,nSamplesPadding)],fs,0);
                    if response(i) == 1 % Common source
                        r_1s = [r_1s r];
                        m_1s = [m_1s MCD_output_signals(1,:)'];
                    else % Separate sources
                        r_2s = [r_2s r];
                        m_2s = [m_2s MCD_output_signals(1,:)'];
                    end
                    all_MCD_corr = [all_MCD_corr, MCD_corr];
                    all_xcorr = [all_xcorr r];
                end
            end
        end
        lag = lag/fs; % Convert from frames to time
        
        %         figure; hold on
        %         for ii = 1:272
        %             plot(lag,m_1s(:,ii),'k')
        %             plot(lag,m_2s(:,ii),'r')
        %         end
        %         plot(lag, mean(m_1s,2) - mean(m_2s,2))
        
        
%         figure;
%         subplot(1,2,1); hist(all_MCD_corr(response(tempConflictYN==1)==1));
%         subplot(1,2,2); hist(all_MCD_corr(response(tempConflictYN==1)==0));
        
        % Compute classification image:
        ccg_1s = mean(r_1s,2);
        ccg_2s = mean(r_2s,2);
        ccg_diff = ccg_1s - ccg_2s;
        smoothingKernal = gausswin(25); % 80 ms
        smoothingKernal = smoothingKernal / sum(smoothingKernal);
        filt_ccg_diff = conv(ccg_diff, smoothingKernal, 'same');
        
        % Plot mean CCGs:
        figure; hold on;
        title(['Subject: ' num2str(sIDs(ii))]);
        xlabel('Lag (sec) ==> (-ve = V 1st,  +ve = A 1st)');
        ylabel('Diff in xcorr');
        xlim([-2 2]);
        plot(lag,ccg_1s,'b');
        plot(lag,ccg_2s, 'r');
        plot(lag,mean([r_1s, r_2s],2),'k')
        
        % Plot raw and smoothed classification image:
        figure; hold on;
        title(['Subject: ' num2str(sIDs(ii))]);
        xlabel('Lag (sec) ==> (-ve = V 1st,  +ve = A 1st)');
        ylabel('Diff in xcorr');
        xlim([-2 2]);
        ylim([-0.02 0.06]);
        plot(lag,ccg_diff,'k');
        plot(lag,filt_ccg_diff,'r')
        
        % Permutation test (switch response labels):
        r_all = [r_1s r_2s];
        N = size(r_all,2);
        sims = 1000;
        nCommon  =sum(response(tempConflictYN==1));
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
        
        % Model fit (Parise & Ernst, 2016):
        [~,idx] = sort(all_MCD_corr,'descend');
        all_xcorr = all_xcorr(:,idx);
        ccg_1s = mean(all_xcorr(:,1:nCommon),2);
        ccg_2s = mean(all_xcorr(:,nCommon+1:end),2);
        ccg_diff = ccg_1s - ccg_2s;
        modelPred = conv(ccg_diff, smoothingKernal, 'same');
        max_behav = max(filt_ccg_diff);
        max_model = max(modelPred);
        modelPred = modelPred * (max_behav / max_model);
        corrcoefval = corrcoef(modelPred,filt_ccg_diff);
        corrcoefval = corrcoefval(1,2);
        
        % Mega summary plot of the gods:
        figure; hold on;
        title(['Subject: ' num2str(sIDs(ii))]);
        xlabel('Light first < ------------- Lag (sec) ------------- > Sound first');
        ylabel('Diff in xcorr');
        xlim([-2 2]);
        ylim([-0.02 0.06]);
        plot(lag,perm_mean,'k')
        plot(lag,perm_lCI, 'color', [0.5 0.5 0.5])
        plot(lag,perm_uCI, 'color', [0.5 0.5 0.5])
        plot(lag,modelPred,'b')
        plot(lag,filt_ccg_diff,'r')
        legend('perm. test','95% CI','95% CI',['model: rho=' sprintf('%0.2f',corrcoefval)],'measured')
    end
end

% http://www.mathworks.com/matlabcentral/answers/5275-algorithm-for-coeff-scaling-of-xcorr
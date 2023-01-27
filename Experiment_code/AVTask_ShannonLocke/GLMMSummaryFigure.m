% Send the data to R!

all_init = {'EN','GK','HL','RD','SL','JZ','MS','PS','MR','EG','DB'};
sIDs = [124 139 876 369 773 308 552 595 940 929 429];

% Empty vectors:
sID = [];
tempConflictYN = [];
maxOffset = [];
propSync = [];
response = [];

for ii = 1:length(all_init) % EACH SUBJECT
    for jj = 1:2 % EACH SESSION
        
        % Find and load file:
        fileNameString = [all_init{ii} '_AVTemporalTask_controlExp_randomSeq_S' num2str(jj)];
        dataPath = ['data_AVTemporalTask_controlExp/' all_init{ii} '/'];
        allMatchedFiles = dir([dataPath fileNameString '*']);
        try
            allMatchedFiles = allMatchedFiles.name;
            load([dataPath allMatchedFiles]);
            
            for kk = 1:size(all_ear,2)
                [~,~,ps(kk)] = get_maxOffset(all_frameType(:,kk),all_ear(:,kk),60);
            end
            
            % Store results:
            % -------------- %
            sID = [sID; repmat(sIDs(ii),size(resMat,1),1)];
            tempConflictYN = [tempConflictYN; resMat(:,2)];
            maxOffset = [maxOffset; resMat(:,3)];
            propSync = [propSync; ps'];
            response = [response; resMat(:,5)];
            
        catch
            fprintf('\n\n Selected file could not be loaded!\n\n');
            disp(allMatchedFiles)
        end
        
    end
end

idx = (tempConflictYN == 1) & (maxOffset < 0.15) & (maxOffset > 0.05) & (propSync < 0.4);
sID = sID(idx);
propSync = propSync(idx);
maxOffset = maxOffset(idx);
response = response(idx);
propSyncRounded = round(propSync/0.2)*0.2;
maxOffsetRounded = maxOffset; % round(maxOffset/0.05)*0.05;
u_ps = unique(propSyncRounded);
u_mo = unique(maxOffsetRounded);
n_ps = length(u_ps);
n_mo = length(u_mo);
n_Ss = length(all_init);
% for ii = 1:n_Ss % EACH SUBJECT
    [ps,mo] = meshgrid(u_ps,u_mo);
    n_resp = NaN(size(ps));
    prop_common = NaN(size(ps));
    nBins = length(ps(:));
   for jj = 1:nBins % EACH BIN
%            idx = (sID == sIDs(ii)) & (propSyncRounded == ps(jj)) & (maxOffsetRounded == mo(jj));
           idx = (propSyncRounded == ps(jj)) & (maxOffsetRounded == mo(jj));
           get_resp = response(idx);
           n_resp(jj) = length(get_resp);
           if ~isempty(n_resp(jj))
               prop_common(jj) = sum(get_resp)/n_resp(jj);
           else 
               prop_common(jj) = NaN;
           end
   end
   % Visualise:
   N = 3;
   M = 5;
   figure;
   subplot(1,2,1);
   colormap(gray);
   imagesc(fliplr(prop_common')');
   colorbar;
   xlabel('Proportion Synchronous');
   ylabel('Maximum Offset (sec)');
   set(gca, 'XTick', 1:N, 'XTickLabel', u_ps);
   set(gca, 'YTick', 1:M, 'YTickLabel', fliplr(u_mo'));
   subplot(1,2,2);
   imagesc(fliplr(n_resp')');
   colorbar;
   xlabel('Proportion Synchronous');
   ylabel('Maximum Offset (sec)');
   set(gca, 'XTick', 1:N, 'XTickLabel', u_ps);
   set(gca, 'YTick', 1:M, 'YTickLabel', fliplr(u_mo'));
   dataPath = '/Users/shannonlocke/GoogleDrive/Library/PosterRepository/posterCRCNS2016/figures/';
   descriptors = {'GLMM','fig'};
   extension = '.txt';
   saveFile = createSaveFileName(descriptors,dataPath,extension);
   x = ps(:);
   y = mo(:)*1000;
   z = prop_common(:);
   T = table(x,y,z);
   writetable(T,saveFile,'Delimiter',' ')
% end
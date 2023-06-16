%% This script creates all the A/V sequences with fixed correlations
% AVseqsFixedCorrs = {ExpInfo.Atrain,ExpInfo.Vtrain,CorrAV_ordered};
nEvents = 5;
allSeqs = perms(1:nEvents);
nSeq = size(allSeqs,1);

% AV corr matrix
Corr = NaN(nSeq, nSeq);
for ii = 1:nSeq
    for jj = 1:nSeq
        Corr(ii,jj) = corr(allSeqs(ii,:)',allSeqs(jj,:)');
    end
end
CorrReshape = reshape(Corr, 1,[]);
figure; histogram(CorrReshape,20)

% construct two arrays with A,V sequences with fixed corr
CorrVal = -1:0.5:1;
nCorr = length(CorrVal); 
nCorrRep = 120; % number of sequences for each correlation
CorrSortedA = cell(nCorrRep,nCorr); %120*5
CorrSortedV = cell(nCorrRep,nCorr);
idxA = NaN(nCorrRep,nCorr); %120*5
idxV = NaN(nCorrRep,nCorr);
for i = 1:nCorr
    [idxA_temp,idxV_temp] = find(Corr > CorrVal(i)-1e-5 &...
        Corr < CorrVal(i)+1e-5); 
    idx_subset = randsample(length(idxA_temp),nCorrRep);
    idxA(:,i) = idxA_temp(idx_subset);
    idxV(:,i) = idxV_temp(idx_subset); 
    % idxA,V correspond to the row numbers in allSeqs. Next, fetch the sequences 
    % from allSeqs and put them into CorrSortedA and CorrSortedV
    for j = 1:nCorrRep
        CorrSortedA{j,i} = allSeqs(idxA(j,i),1:end);
        CorrSortedV{j,i} = allSeqs(idxV(j,i),1:end);
    end
end

% reshape 
% These are the A/V sequences we present in this experiment. Cols are
% centroids of the sequences, rows are the sequences
% p.s.The same sequences are also used for the main expt where we manipulate corr
Atrain_temp         = reshape(CorrSortedA, [], 1); %600*1
Vtrain_temp         = reshape(CorrSortedV, [], 1); %600*1
disc                = (4:5:29)-3; %discrepancies
ExpInfo.centroids   = [4,9,14,19,24,29]; %location numbers, not actual dvg
ExpInfo.Atrain      = repmat(Atrain_temp,[1,6]); 
ExpInfo.Vtrain      = repmat(Vtrain_temp,[1,6]);
for i = 1:6
    for j = 1:600
        ExpInfo.Atrain{j,i} = ExpInfo.Atrain{j,i} + disc(i);
        ExpInfo.Vtrain{j,i} = ExpInfo.Vtrain{j,i} + disc(i);
    end
end

%In ExpInfo.Atrain and ExpInfo.Vtrain, Columns contain A/V trains centered 
%at [1 6 11 16 21 26], respectively
%Rows contain 600 different sequences with the same centroid (randomly draw 
%from these sequences during the experiment)

CorrAV_ordered = NaN(600,1); %check corr
for j = 1:600
  CorrAV_ordered(j) = corr(ExpInfo.Atrain{j,1}',ExpInfo.Vtrain{j,1}');
end


%% save files
AVseqsFixedCorrs = {ExpInfo.Atrain,ExpInfo.Vtrain,CorrAV_ordered};
save('AVseqsFixedCorrs');


% This script generates two arrays of sequences (A and V) with fixed correlations
% (-1:0.1:1) using brute force. There are 120 different pairs of AV sequences 
% for each correlation. So the size of these arrays is {120,21}.

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
CorrVal = -1:0.1:1;
nCorr = length(CorrVal); 
nCorrRep = 120; % number of sequences for each correlation
CorrSortedA = cell(nCorrRep,nCorr); %120*21
CorrSortedV = cell(nCorrRep,nCorr);
idxA = NaN(nCorrRep,nCorr); %120*21
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

% check correlation 
CorrCheck = NaN(nCorrRep,nCorr);
for i = 1:nCorr
    for j = 1:nCorrRep
        CorrCheck(j,i) = corr(CorrSortedA{j,i}',CorrSortedV{j,i}');
    end
end
    

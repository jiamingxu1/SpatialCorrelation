%% notes
% 1. random orders is going to be very hard, can we do single order (left to
% right) -- try it out and see. We won't have enough repetitions if we do
% that
% 2. can we keep the window 5, so the centroid within a window would be the
% same and wouldn't need distance metrics (yes, make sure there are enough
% repetitions)
%% window = 8
% all possible combinations (window = 8)
n = 8; k = 5;
nk = nchoosek(1:n,k); 
p=zeros(0,k);
for i=1:size(nk,1)
    pi = perms(nk(i,:));
    p = unique([p; pi],'rows');
end

% generate a subset 
nSeq = 1e5;
A = NaN(nSeq,5);
B = NaN(nSeq,5);
corrAB = NaN(nSeq,1);
for i = 1:nSeq
    A(i,:) = randperm(8,5);
    B(i,:) = randperm(8,5);
    corrAB(i) = corr(A(i,:)',B(i,:)');
end
figure; histogram(corrAB)
sortedCorrAB = sort(corrAB); % sort

% centroid
meanA = NaN(nSeq,1);
for i = 1:nSeq
    meanA(i) = mean(A(i,:));
end
figure; histogram(meanA)

% distance metric
L1 = NaN(nSeq, 1);
L2 = NaN(nSeq, 1);
for i  =1:nSeq
    L1(i) = sum(abs(A(i,:) - meanA(i)));
    L2(i) = sum((A(i,:) - meanA(i)).^2);
end
figure; histogram(L1); histogram(L2)
sum(L1 == 10);

% find corr = -1 index
sum(corrAB == -1)
idx_perfCorr = find(corrAB==-1);
% find corr within a range index
histcounts(corrAB,[-1 -0.8])
idx = find(corrAB>-1 & corrAB<-0.8);

%% window = 5
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
    
% construct two cell arrays with A and V sequences with fixed corr
CorrVal = -1:0.1:1;
nCorr = length(CorrVal); % number of possible correlations
nCorrRep = 120; % number of sequences per correlation
CorrSortedA = cell(nCorrRep,nCorr); % 120*21, 120 sequences for each corr
CorrSortedV = cell(nCorrRep,nCorr);
idxA = NaN(nCorrRep,nCorr); %120*21
idxV = NaN(nCorrRep,nCorr);
for i = 1:nCorr
    [idxA_temp,idxV_temp] = find(Corr > CorrVal(i)-1e-5 &...
        Corr < CorrVal(i)+1e-5); 
    idx_subset = randsample(length(idxA_temp),nCorrRep);
    idxA(:,i) = idxA_temp(idx_subset);
    idxV(:,i) = idxV_temp(idx_subset); 
    % idxA,V correspond to the row numbers in allSeqs, next fetch the sequences 
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
    

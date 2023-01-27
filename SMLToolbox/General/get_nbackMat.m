function [nbackMat] = get_nbackMat(X,n,concatYN)
%
%
% Created by SML Dec 2017

% Defaults:
if nargin < 3
    concatYN = 1;
    if nargin < 2
        n = 1;
    end
end

% Input checks:
N = size(X,1);
if N-n < 1; error('Sequence length must be greater than n!'); end

% Switch from row to column vector if necessary:
if size(X,1) == 1; X = X'; end

% Set up:
idx = (n+1):N;
nSeq = size(X,2);
X = [X; nan([n,nSeq])];
nbackMat = nan([N-n,nSeq,n+1]);

% Fill in entries:
nbackMat(:,:,1) = X(idx,:);
for ii = 1:n
    X = circshift(X,1,1);
    nbackMat(:,:,ii+1) = X(idx,:);
end

% Squeeze 1D, 2D concatinate if need be or permute axes otherwise:
if size(X,2) == 1
    nbackMat = squeeze(nbackMat);
else
    switch concatYN
        case 0
            nbackMat = permute(nbackMat,[1,3,2]);
        case 1
            nbackMat = reshape(nbackMat,[nSeq*(N-n),n+1]);
    end
end

end
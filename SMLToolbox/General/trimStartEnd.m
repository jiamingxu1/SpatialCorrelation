function [X,Y] = trimStartEnd(X,Y,n,dim)
% [X,Y] = trimStartEnd(X,Y,n,dim) is a function that removes the first n
% entries of X and the last n enrties of Y. X and Y can be vectors or 
% matrices (2D or 3D). Also, X and Y need not be the same size. The input
% dim allows you to specifiy which dimension is to be trimmed. Supply one
% value if the same dimension is to be trimmed for X and Y, or a two
% element vector for the respective dimensions of X and Y. Defaults: trim
% only one element, trim the 1st dimension (rows).
%
% Created by SML Jan 2017.

% Defaults:
if nargin < 4
    dim = 1;
   if nargin < 3
      n = 1; 
   end
end

% Trim the same dimension if only one input supplied:
if length(dim) == 1
    dim = [dim dim];
end

% Get initial lengths:
nX = size(X,dim(1));
nY = size(Y,dim(2));
idxX = (n+1):nX;
idxY = 1:(nY-n);

% Checks:
assert(round(n)==n, 'The value of n supplied is not an integer!')
assert(length(dim)<=2, 'Supply up to two dimensions (1 for X, 1 for Y, or 1 for both)')
assert(max(dim)<=3, 'This function cannot handle dimensions greater than 3!')
assert(nX>=n, 'The number of elements to be trimmed in X is larger than X! Check dim and n inputs.')
assert(nY>=n, 'The number of elements to be trimmed in Y is larger than Y! Check dim and n inputs.')

% Trim X:
switch dim(1)
    case 1
        X = X(idxX,:,:);
    case 2
        X = X(:,idxX,:);
    case 3
        X = X(:,:,idxX);
end

% Trim Y:
switch dim(2)
    case 1
        Y = Y(idxY,:,:);
    case 2
        Y = Y(:,idxY,:);
    case 3
        Y = Y(:,:,idxY);
end

end
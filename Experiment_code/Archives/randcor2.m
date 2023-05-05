function X=randcor2(n,r)
% RANDCOR2 Generates correlated uniform random variables
% X=randcor2(n,r) returns an nx2 matrix of n bivariates

% with uniform marginals and correlation r.

U = -1 + 2*rand(2,n);
C = [1 r; r 1]; [V,D] = eig(C); % lambdas = diag(D);

W = V*sqrt(3 * D);
X = (W*U)';
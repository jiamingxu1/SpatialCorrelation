function X = randcorr(n,r)
% RANDCORR Generates correlated uniform random variables
% X=randcorr(n,r) returns an nx2 matrix of n bivariates
% with uniform marginals and correlation r.

c = 2*sin(pi/6 * r);
R = [1 c; c 1];

X = normcdf(randn(n,2)*chol(R));
end


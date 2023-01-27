% This script tests meanOfTruncNormal.m. For the math, see: 
% https://math.stackexchange.com/questions/445164/is-the-mean-of-the-truncated-normal-distribution-monotone-in-mu
%
% Created by SML July 2019

tol = 0.001; % tolerance between computational and analytical answers.
effectiveInfinity = 10^10; % value to use in place of infinity

%% Case 1, +/- 1 SD:
%
% Answer = 0.

mu = 0;
sigma = 1;
bounds = [-1 1];
test = meanOfTruncNormal(mu,sigma,bounds);
if test == 0
    disp('Case 1, +/- 1 SD: PASSED.')
else
    disp('Case 1, +/- 1 SD: FAILED.')
    disp(['Mean value should be 0. It was ' num2str(test)])
end

%% Case 1, -1 +2 SD:
%
% Answer compuatationally derived.

mu = 0;
sigma = 1;
bounds = [-1 2];
test = meanOfTruncNormal(mu,sigma,bounds);
xvals = linspace(-4*sigma,4*sigma,1000);
yvals = normpdf(xvals,mu,sigma);
yvals(xvals < bounds(1)) = 0;
yvals(xvals > bounds(2)) = 0;
yvals = yvals/sum(yvals);
meanComp = dot(xvals,yvals);
if abs(meanComp - test) < tol
    disp('Case 2, -1 +2 SD: PASSED.')
else
    disp('Case 1, -1 +2 SD: FAILED.')
    disp(['Mean value should be ' num2str(meanComp) '. It was ' num2str(test)])
end

%% Case 3, -2 +1 SD:
%
% Answer compuatationally derived.

mu = 0;
sigma = 1;
bounds = [-2 1];
test = meanOfTruncNormal(mu,sigma,bounds);
xvals = linspace(-4*sigma,4*sigma,1000);
yvals = normpdf(xvals,mu,sigma);
yvals(xvals < bounds(1)) = 0;
yvals(xvals > bounds(2)) = 0;
yvals = yvals/sum(yvals);
meanComp = dot(xvals,yvals);
if abs(meanComp - test) < tol
    disp('Case 3, -2 +1 SD: PASSED.')
else
    disp('Case 3, -2 +1 SD: FAILED.')
    disp(['Mean value should be ' num2str(meanComp) '. It was ' num2str(test)])
end

%% Case 4, diff mu and sigma:
%
% Answer compuatationally derived.

mu = 2;
sigma = 4;
bounds = [-1 1];
test = meanOfTruncNormal(mu,sigma,bounds);
xvals = linspace(-4*sigma,4*sigma,1000);
yvals = normpdf(xvals,mu,sigma);
yvals(xvals < bounds(1)) = 0;
yvals(xvals > bounds(2)) = 0;
yvals = yvals/sum(yvals);
meanComp = dot(xvals,yvals);
if abs(meanComp - test) < tol
    disp('Case 4, diff mu and sigma: PASSED.')
else
    disp('Case 4, diff mu and sigma: FAILED.')
    disp(['Mean value should be ' num2str(meanComp) '. It was ' num2str(test)])
end

%% Case 5, lower bound negative infinity:
%
% Answer compuatationally derived.

mu = 0;
sigma = 1;
bounds = [-effectiveInfinity 1];
test = meanOfTruncNormal(mu,sigma,bounds);
xvals = linspace(-4*sigma,4*sigma,1000);
yvals = normpdf(xvals,mu,sigma);
yvals(xvals < bounds(1)) = 0;
yvals(xvals > bounds(2)) = 0;
yvals = yvals/sum(yvals);
meanComp = dot(xvals,yvals);
if abs(meanComp - test) < tol
    disp('Case 5, lower bound negative infinity: PASSED.')
else
    disp('Case 5, lower bound negative infinity: FAILED.')
    disp(['Mean value should be ' num2str(meanComp) '. It was ' num2str(test)])
end

%% Case 6, upper bound positive infinity:
%
% Answer compuatationally derived.

mu = 0;
sigma = 1;
bounds = [-1 effectiveInfinity];
test = meanOfTruncNormal(mu,sigma,bounds);
xvals = linspace(-4*sigma,4*sigma,1000);
yvals = normpdf(xvals,mu,sigma);
yvals(xvals < bounds(1)) = 0;
yvals(xvals > bounds(2)) = 0;
yvals = yvals/sum(yvals);
meanComp = dot(xvals,yvals);
if abs(meanComp - test) < tol
    disp('Case 6, upper bound positive infinity: PASSED.')
else
    disp('Case 6, upper bound positive infinity: FAILED.')
    disp(['Mean value should be ' num2str(meanComp) '. It was ' num2str(test)])
end

%% 

mu = 0;
sigma = 1;
bounds = [-effectiveInfinity 0];
testL = meanOfTruncNormal(mu,sigma,bounds);
bounds = [0 effectiveInfinity];
testR = meanOfTruncNormal(mu,sigma,bounds);

xvals = linspace(-4*sigma,4*sigma,1000);
yvals = normpdf(xvals,mu,sigma);
0.5/normcdf(0)



yvals(xvals < bounds(1)) = 0;
yvals(xvals > bounds(2)) = 0;
yvals = yvals/sum(yvals);
meanComp = dot(xvals,yvals);
if abs(meanComp - test) < tol
    disp('Case 6, upper bound positive infinity: PASSED.')
else
    disp('Case 6, upper bound positive infinity: FAILED.')
    disp(['Mean value should be ' num2str(meanComp) '. It was ' num2str(test)])
end
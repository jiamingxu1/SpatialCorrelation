% Fisher's Linear Discriminant Tutorial:
% This tutorial follows Bishop's exposition in Pattern Recognition and
% Machine Learning (Sect. 4.1.4).
% 
% Created by SML Juin 2019

%% Create a 2D example dataset:

% Define sampling distributions:
N1 = 1000; % number of observations of Class 1
N2 = 100; % number of observations of Class 2
mu1 = [5, 8]; % mean of Class 1
mu2 = [8, 5]; % mean of Class 2
sigma1 = [2.5 2; 2 5]; % covariance matrix for Class 1
sigma2 = [2.5 1.5; 1.5 5]; % covariance matrix for Class 2

% Draw samples:
C1 = mvnrnd(mu1,sigma1,N1); % Class 1 samples
C2 = mvnrnd(mu2,sigma2,N2); % Class 2 samples

% Visualise simulation:
figure; hold on
plot(C1(:,1),C1(:,2),'bo')
plot(C2(:,1),C2(:,2),'ro')

%% Manually perform FLD:

% solution: v = C^{-1} (mu_A - mu_B), where C = C_A + C_B

% Get sample mean and variance:
muEst1 = mean(C1); % Estimated Class 1 mean
muEst2 = mean(C2); % Estimated Class 2 mean
CovEst1 = cov(C1); % Estimated covariance of Class 1
CovEst2 = cov(C2); % Estimated covariance of Class 2
SumCov = CovEst1 + CovEst2; % C term

% mean subtract data:
muMidpt = (muEst2 + muEst1)/2;
C1 = C1 - muMidpt;
C2 = C2 - muMidpt;
muEst1 = mean(C1); % Update Class 1 mean
muEst2 = mean(C2); % Update Class 2 mean

% Compute discriminant:
v = inv(SumCov) * (muEst2 - muEst1)'; % Discriminant coefficients
v = v'; 

% Visualise fit:
figure; hold on
plot(C1(:,1),C1(:,2),'bo')
plot(C2(:,1),C2(:,2),'ro')
f = @(x1,x2) v(1)*x1 + v(2)*x2; % Linear discriminant function
h2 = fimplicit(f,[-10 10 -10 10]);

% Visualise separation:
proj1 = v * C1';
proj2 = v * C2';
if length(proj1) > length(proj2)
    proj2(end+1:length(proj1)) = nan;
elseif length(proj1) < length(proj2)
    proj1(end+1:length(proj2)) = nan;
end
figure; hist([proj1' proj2'])

% Categorise new samples:
newC1 = mvnrnd(mu1,sigma1);
newC2 = mvnrnd(mu2,sigma2);
projNew1 = v * newC1';
projNew2 = v * newC2';
% k = v * muEst2' + v * muEst1';

%% Check fit with Matlab function for FLD analysis:

meas = [C1; C2]; % combine measurements
class = [ones([N1,1]); 2*ones([N2,1])]; % class info
MdlLinear = fitcdiscr(meas,class); % fit FLD
D1 = meas(:,1); % get 1st dimension values
D2 = meas(:,2); % get 2nd dimension values
K = MdlLinear.Coeffs(1,2).Const; % Constant for discriminant line
L = MdlLinear.Coeffs(1,2).Linear; % ??? for discriminant line
f = @(x1,x2) K + L(1)*x1 + L(2)*x2; % Linear discriminant function

% Visualise:
figure; hold on
h1 = gscatter(D1,D2,class,'br','ov',[],'off');
h2 = fimplicit(f,[-2 14 -2 14]);
legend('Class 1','Class 2','FLD','NewSample','Location','best')

% Get new Class 2 sample and classify:
newSample = mvnrnd(mu2,sigma2,1);
plot(newSample(1),newSample(2),'go')
pred = predict(MdlLinear,newSample);
disp(['The new sample was categorised as Class ' num2str(pred)])
function [] = getPFs_expName(indata)
% Template for psychometric function fit using rstan
%
% Created by SML Jan 2017

% File locations:
projectName = 'projectName';
expName = 'expName';
if ~isempty(projectName)
    dataPath = ['/Users/shannonlocke/GoogleDrive/Library/Experiments/' projectName '/' expName '/DataAnalysis/data_raw_' expName '/'];
else
    dataPath = ['/Users/shannonlocke/GoogleDrive/Library/Experiments/' expName '/DataAnalysis/data_raw_' expName '/'];
end

% Prep raw data:
% This is going to depend on the stucture of your data...

% Model parameters:
mu = [-1 1];
sigma = [0.5 3];
iter = 1000;
chains = 4;

% Export data to R:
fitPFs_rstan(PF,stimLevel,resp,mu,sigma,iter,chains,dataPath);
disp('Data export complete.')

% Run script in R:
disp('Run analysis script in R now.')
pause

% Load PF fit results:
dataPath = [dataPath_computerSpecific '/data_analysed_' expName '/'];
indata = readtable([dataPath 'fitPF_paramVals'],'Delimiter',' ');

end

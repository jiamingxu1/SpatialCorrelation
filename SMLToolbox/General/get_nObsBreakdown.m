function [N,stimVal,respVal,confVal] = get_nObsBreakdown(stimClass,resp,conf)
% [N,stimVal,respVal,confVal] = get_nObsBreakdown(stimClass,resp,conf) is a
% function to get the counts for a traditional SDT analysis (hits, misses,
% false alarms, correct rejects). The code also has the flexibility to do
% this conditioned on confidence reponse.
% 
% Structure:
% [stim=low,resp=low;   stim=low,resp=high;
%  stim=high,resp=low;  stim=high,resp=high]
% (x2 for conf, low than high)
%
% Created by SML Dec 2017

% Defaults:
if nargin < 3
    conf = [];
end

% Checks:
if length(unique(stimClass)) ~= 2; error('StimClass must be a binary variable.'); end
if length(unique(resp)) ~= 2; error('Resp must be a binary variable.'); end
if length(unique(conf)) ~= 2; error('Conf must be a binary variable.'); end

% Explanatory matrices:
if isempty(conf)
    withConfYN = 0;
    confVal = [];
    % Create explanatory matrix stimVal:
    stimVal = ones([2,2]);
    stimVal(1,:) = min(stimClass) * stimVal(1,:);
    stimVal(2,:) = max(stimClass) * stimVal(2,:);
    % Create explanatory matrix respVal:
    respVal = ones([2,2]);
    respVal(:,1) = min(resp) * respVal(:,1);
    respVal(:,2) = max(resp) * respVal(:,2);
else
    withConfYN = 1;
    % Create explanatory matrix confVal:
    confVal = ones([2,2,2]);
    confVal(:,:,1) = min(conf) * confVal(:,:,1);
    confVal(:,:,2) = max(conf) * confVal(:,:,2);
    % Create explanatory matrix stimVal:
    stimVal = ones([2,2,2]);
    stimVal(1,:,:) = min(stimClass) * stimVal(1,:,:);
    stimVal(2,:,:) = max(stimClass) * stimVal(2,:,:);
    % Create explanatory matrix respVal:
    respVal = ones([2,2,2]);
    respVal(:,1,:) = min(resp) * respVal(:,1,:);
    respVal(:,2,:) = max(resp) * respVal(:,2,:);
end

% Compute if correct or incorrect:
corrYN = (stimClass .* resp + 1)/2;

% Calculate N:
switch withConfYN
    case 0
        [x,~,c,n] = get_PCorr(stimClass,resp);
        N = [c(1) n(1)-c(1); n(2)-c(2) c(2)];
    case 1
        N = ones([2,2,2]);
        [x,~,c,n] = get_PCorr(stimClass(conf==min(conf)),corrYN(conf==min(conf)));
        N(:,:,1) = [c(1) n(1)-c(1); n(2)-c(2) c(2)];
        [x,~,c,n] = get_PCorr(stimClass(conf==max(conf)),corrYN(conf==max(conf)));
        N(:,:,2) = [c(1) n(1)-c(1); n(2)-c(2) c(2)];
end

end
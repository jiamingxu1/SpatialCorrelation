function [] = plotPF_rawData(x,y,plotOverlayYN,subplotYN)
% This plotting function takes raw stimulus level and response data as
% input and will compute suitable bin sizes for the data, generating a raw
% data plot of the psychometric function. Multiple datasets can be given by
% inputing a matrix instead of a vector for x and y. Note that columns will
% be treated as separate datasets. plotOverlayYN is a toggle for whether
% different datasets should be plotted on the same graph or different
% graphs. If set to off (0), the subplotYN toggle will determine of the
% separate raw data plots are subplots within a figure or each has its own
% figure window.
%
% Created by SML July 2018

% Defaults:
if nargin < 4
    subplotYN = 1;
    if nargin < 3
        plotOverlayYN = 1;
    end
end

% Determine the number of raw data functions:
if isvector(x)
    nplots = 1;
else
    nplots = size(x,1);
end

% Determine appropriate binning:
xdiff = max(x) - min(x);
if xdiff > 300
    rval = 100;
elseif xdiff < 300 && xdiff > 150
    rval = 50;
elseif xdiff < 150 && xdiff > 50
    rval = 10;
elseif xdiff < 50 && xdiff > 20
    rval = 5;
elseif xdiff < 20 && xdiff > 8
    rval = 2;
elseif xdiff < 8 && xdiff > 4
    rval = 1;
elseif xdiff < 4 && xdiff > 1
    rval = 0.25;
elseif xdiff < 1 && xdiff > 0.3
    rval = 0.1;
else
    rval = 0.05;
end

% Get count data:
[X,P,N,C] = get_PCorr(x,y,rval);

% Plot
if plotOverlayYN == 1
    figure
    plot(X,P,'-o');
    ylim([0 1])
else 
    
end

end

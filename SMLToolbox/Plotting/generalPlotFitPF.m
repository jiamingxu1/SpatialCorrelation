function [] = generalPlotFitPF(saveFile,mu,sigma,stimLevel,resp,xTitle,yTitle,plotTitle,rval,maxN,plotCols,legendStr)
% ...
% 
% INPUT:
% saveFile:- the name you want to give to the figure file
% mu:- the fit mu parameter
% sigma:- the fit sigma parameter
% stimLevel:- a vector of stimulus level for each trial
% resp:- a vector of response values
% xTitle:- the x axis label
% yTitle:- the y axis label
% plotTitle:- the name to place on the top of the plot
% rval:- for binning the raw data, a multiple value all stimLevel will be rounded to
% maxN:- maximum number of data points per bin (can leave empty if unknown)
% plotCols:- a matrix (Nx3) specifying rgb colour values for plots (can leave empty)
% legendStr:- a cell of legend entries (can leave empty)
%
% Need to extend to multiple PFs...
%
% Created SML Feb 2017

% Defaults:  
if nargin < 12
    legendStr = [];
    if nargin < 11
        plotCols = [];
        if nargin < 10
            maxN = [];
            if nargin < 9
                rval = [];
                if nargin < 8
                    plotTitle = [];
                    if nargin < 7
                        yTitle = [];
                        if nargin < 6
                            xTitle = [];
                        end
                    end
                end
            end
        end
    end
end

% Check input dimensions match:
assert(all(size(stimLevel)==size(resp)),'The stimulus level and response inputs do not match')
assert(length(mu)==length(sigma),'The mu and sigma inputs do not match')
assert(length(mu)==size(stimLevel,2),'The # PF parameters must match the number of columns of the raw data')

% Get raw data data-points:
[X,P,~,C] = get_PCorr(stimLevel,resp,rval);
nX = length(X);
nPFs = size(stimLevel,2);

% Get fitted PF function:
xvals = linspace((floor(min(X))-0.03*abs(min(X))),(ceil(max(X))+0.03*abs(max(X))));
nn = length(xvals);
yvals = normcdf(repmat(xvals',[1,nPFs]),repmat(mu,[nn,1]),repmat(sigma,[nn,1]));

% General properties of the figure:
hh = figure('position', [0, 0, 700, 500]); hold on
set(gca,'Fontsize', 14, 'LineWidth', 2);
if (isempty(maxN)) || maxN < max(C(:)); % not specified or not large enough
    maxN = 10*ceil(max(C(:))/10); 
end
cbrange = round(linspace(0,maxN,11));

% Picking some colours:
if isempty(plotCols)
    if nPFs == 1
        plotCol = [0 0 0]; % single black line
    else
        plotCol = gradCustCol(nPFs, [0 0 1], [1 0 0]); % gradient from blue to red
    end
end
col = gradCustColBar(maxN,cbrange,[1 1 1],[0 0 0],'Number of Trials'); 


% Add plot elements:
for pf = 1:nPFs
    plot(xvals,yvals(:,pf),'-','Color',plotCol(pf,:),'LineWidth',3);
end
if ~isempty(legendStr); legend(legendStr,'Location','NorthWest'); legend boxoff; end % add legend if supplied
for pf = 1:nPFs
    for ii = 1:nX
        mkrCol = plotCol(pf,:) + col(C(ii,pf),:).*([1 1 1] - plotCol(pf,:));
        plot(X(ii),P(ii,pf),'o','Color',plotCol(pf,:),'MarkerFaceColor',mkrCol,'MarkerSize',8,'LineWidth',1.5)
    end
end

% Set some boundaries, name shit:
ylim([-0.01 1.01])
xlim([min(xvals),max(xvals)])
xlabel(xTitle,'Fontsize', 16)
ylabel(yTitle,'Fontsize', 16)
title(plotTitle, 'Fontsize', 18)

% Save as eps:
set(hh, 'PaperPositionMode', 'auto');
saveas(hh,saveFile,'epsc')
close

end
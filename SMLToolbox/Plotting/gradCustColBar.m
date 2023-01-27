function [col] = gradCustColBar(nCol, cbrange, gradStart, gradEnd, cbTitle)
% GRADCUSTCOLBAR is a function to handle the nitty-gritty of getting a
% custom gradient colour change colour bar for plotting. Use the input
% colours to colour each separate plot. 
%
% -- INPUTS --
% NCOL: set to the number of functions to be plotted or gradient levels 
% desired.
% CBRANGE: this will be the colour bar axis labels. Can enter vector of
% numbers or a cell of labels (optional, default 1-nCol).
% GRADSTART: the rgb code for the first function (optional, default 
% [0 0 1]. If you would like to specify the colours, enter your rgb colour
% matrix as 'gradStart', and do not include 'gradEnd'.
% GRADEND: the rgb for the final function. Note that all other functions
% will be assigned a colour along the gradient from the first to last
% function (optional, default [1 0 1]). 
%
% -- OUTPUTS --
% COL: is the colour matrix for plotting functions.
%
% Created by SML Dec 2014

% Defaults
if nargin < 5
    cbTitle = [];
    if nargin < 4
        gradend = [1 0 1];
        if nargin < 3
            gradStart = [0 0 1];
            if nargin < 2
                cbrange = 1:nCol;
            end
        end
    end
end
if isempty(gradEnd)
    gradEnd = [1 0 1];
    if isempty(gradStart)
        gradStart = [0 0 1];
        if isempty(cbrange)
            cbrange = 1:nCol;
        end
    end
end

% Get colour gradient:
if isvector(gradStart)
rr = (linspace(gradStart(1),gradEnd(1),nCol))';
gg = (linspace(gradStart(2),gradEnd(2),nCol))';
bb = (linspace(gradStart(3),gradEnd(3),nCol))';
col = [rr gg bb];
elseif size(gradStart,1) == nCol
    col = gradStart;
else
    error('Incorrect gradStart or gradEnd entry')
end

% Interpret labels:
if ~iscell(cbrange) % convert to cell of strings:
    cbrange = strread(num2str(cbrange),'%s');
end 
nLab = length(cbrange); % number of labels 
   
% Make colour bar:
try
    cbh = colorbar;
    colormap(col);
    set(cbh,'Ytick',1+(0:(nCol-1)/(nLab-1):(nCol-1)))
    set(cbh,'Yticklabel',cbrange)
    set(get(cbh,'ylabel'),'String',cbTitle,'fontSize',12);
catch
    disp('You miss out on pretty colour bar!')
end
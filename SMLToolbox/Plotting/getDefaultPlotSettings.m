function [figSet] = getDefaultPlotSettings()
% GETDEFAULPLOTSETTINGS creates a structure with all the default values
% to be used with the function makeFigureSexyAF.m. If you would like to use
% settings other than the default, change the figSet structure before
% calling makeFigureSexyAF.m.
%
% OUTPUT:
% figSet:- structure with default settings.
%
% Created SML August 2015

% Data series:
% figSet.specstr = 'k-o'; % specifies: colour, line type, marker type
figSet.col = [0 0 0]; % data series line colour
figSet.line = '-'; % line type 
figSet.marker = 'o'; % marker type
figSet.MS = 3; % marker Size

% Axes:
figSet.FS = 18; % Font size
figSet.LW = 3; % Line width


end
function [dataPath] = readData_findDataFolder(expName,preSel)
% [dataPath] = READDATA_FINDDATAFOLDER(expName.preSel) will source the
% data folder for the experiment specified by 'expName'. If you are not
% using the same folder organising convention that I use, you can also
% enter in a prespecified path using 'preSel'. This code will check that
% folder exists, and open a pop-up window for you to find it if it is
% written down wrong.
%
% Created by SML Aug 2016

if nargin < 2
    preSel = [];
end

% Default data folder
if isempty(preSel)
    dataPath = ['../RunExperiment' filesep 'data_', expName];
else
    dataPath = preSel;
end

% If it's not on Shannon's Laptop, check current folder and error if not found:
if ~isdir(dataPath)
    warning(['The following data folder could not be found:', dataPath]);
    disp('Checking current folder instead...')
    dataPath = ['data_', expName];
    if ~isdir(dataPath)
        error(['The following data folder could not be found:   ', dataPath]);
    end
    
end
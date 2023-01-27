function [exp] = readData(expName, subject, session, cond)
% [exp] = READDATA(expName,subject,session, cond) will return the contents 
% of the  data file for subject, session, and condition specified in the 
% experiment 'expName'. Typically the cond argument goes unused so the
% function will default to cond = '' if nothing is specified.
%
% Created by SML July 2016

% Defaults:
if nargin < 4
    cond = '';
end

% Find data folder:
dataPath = readData_findDataFolder(expName);

% Prepare output in case of failure to find file:
exp = [];

try % Try to extract file
    dataPath = [dataPath filesep subject]; % w. subject directory
    fileIncomplete = [dataPath filesep subject '_' expName '_' cond '_S' num2str(session) '_*.mat'];
    d = dir(fileIncomplete);
    allFiles = {d.name};
    if length(allFiles) == 1 % select matching file
        load([dataPath filesep allFiles{1}])
    else % select from multiple files
        disp('Multiple files found')
        YN = 0;
        while (YN ~= 1 && YN ~= 5)
        [selFile, selPath] = uigetfile([dataPath filesep '*.mat'], 'Select the file that you wish to use.');
        disp(['You have selected: ' selFile])
        YN = input('Is this correct?, Press 0 for no, 1 for yes, and 5 to give up.');
        end
        if YN == 1
            load([selPath filesep selFile])
        elseif YN == 5
            return
        end
    end
catch % Report failure to find any files, return
    disp('The following file could not be found:')
    disp(fileIncomplete)
    return
end

% Handle recent renaming of exp to EXP to avoid conflict with function of the same name:
if exist('EXP'); exp = EXP; end

end
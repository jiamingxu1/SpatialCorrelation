function [VIS] = get_viewingConditions(hardware,preSel)
% GET_VIEWINGCONDITIONS This code will load or create the information
% needed for calibrating the stimuli to the particular display. 
%
% [VIS] = get_viewingConditions(HARDWARE,PRESEL)
%
% HARDWARE: Run prepDevices to get information about the screen stored in
%           a structure called hardware.
% PRESEL: A string that allows you to pre-select a particular viewing
%         condition file. Best used for debugging, but if you are running
%         the experiment you should leave this off, so you are always 
%         checking your settings before each run.
%
% VIS: A structure containing the information about the viewing conditions.
%
% Created by SML April 2015

if nargin < 2
    preSel = [];
end

% Reminder of viewing condition if preselected:
if ~isempty(preSel)
    disp(['WARNING: You have preselected the following viewing condition file:' preSel])
end

% Determine where the data is stored:
dataPath = '/Users/shannonlocke/Documents/Research/Library/SMLToolbox/Experiments/ViewingConditions';
if ~isfolder(dataPath)
    dataPath = 'ViewingConditions'; % Generic option (in folder with exp files)
end
if ~isfolder(dataPath)
    mkdir(dataPath) % If it doesn't exist yet, make it!
end

% Load pre-selected option (good for debugging):
if ~isempty(preSel)
    try
        load([dataPath filesep preSel])
        disp(['Loaded ' preSel])
    catch
        preSel = [];
        disp('Your pre-selected option could not be found.')
        disp('The following steps will help you find or create it.')
    end
end

% Find or create the viewing conditions file:
if isempty(preSel)
    
    disp('Existing subject data directories: ')
    ls(dataPath)
    selViewCond = upper(input('Please enter which set up you would like to load or press enter to create a new file: ','s'));
    
    % Load the selected view conditions:
    if ~isempty(selViewCond)
        done = 0;
    while done ==0
        try
            load([dataPath filesep selViewCond])
            disp(['Loaded ' selViewCond])
            done = 1;
        catch
            disp('The file you entered could not be found.')
            disp('Try again, or press enter to create a new file.')
            selViewCond = upper(input('Please enter which set up you would like to load: ','s'));
            if ~isempty(selViewCond)
                done = 1;
            end
        end
    end
    end
    
    % Create new viewing conditions file:
    new = 0;
    if isempty(selViewCond)   
        new = 1;
        % Name for new viewing conditions file:
        nameViewCond = upper(input('Please enter a name for this set up: ','s'));
        % Distance Ss are seated from screen:
        VIS.viewDist = input('Please enter the viewing distance (in cm): ');
        % Size of screen in cm:
        VIS.screenSize(1) = input('Please enter the screen width (in cm): ');
        VIS.screenSize(2) = input('Please enter the screen height (in cm): ');
        % Pixels per cm (average of height/width if they differ):
        VIS.pixPerCm = mean(hardware.screenRes ./ VIS.screenSize);
        % Pixels per degree:
        VIS.pixPerDeg = VIS.pixPerCm * 2 * VIS.viewDist * tan(0.5*(pi/180));
        disp([selViewCond ' was created'])
        % use CalibrateMonitorPhotometer to do gamma correction
    end
    
    % Confirm selection/creation:
    confirmed = 0;
    while confirmed == 0
        disp('Are you happy with these settings:')
        disp(VIS)
        confirmed = input('Press enter for yes, or 0 for no: ');
        if confirmed == 0
            VIS = get_viewingConditions(hardware);
            new = 0;
        end
    end
    
    % Save if new viewing conditions file:
    if new == 1
        save([dataPath filesep nameViewCond],'VIS');
    end
    VIS.testSetup = nameViewCond;
    
end

end
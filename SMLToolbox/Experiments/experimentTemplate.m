function [exp] = experimentTemplate(subject,session,condition,mode,restartYN)
%
% Created by SML Nov 2020

% Defaults:
if nargin < 5
    restartYN = false;
    if nargin < 4
        mode = 'demo';
        if nargin < 3
            condition = '';
            if nargin < 2
                session = 0;
                if nargin < 1
                    subject = 'TEST';
                end
            end
        end
    end
end
if isempty(subject); subject = 'TEST'; end
if isempty(session); session = 0; end
if isempty(condition); condition = ''; end
if isempty(mode); mode = 'demo'; end
if isempty(restartYN); restartYN = false; end

% Input checks:
if ~any(strcmp(mode,{'demo','training','test','pilotTraining','pilotTest'}))
    error('Unknown mode type.')
end

% -------------------
% Experiment Settings
% -------------------

p1_expSettings;
v2struct(expDesign);
exp.designMat = designMat;
exp.designMat_Legend = designMat_Legend;
exp.expDesign = expDesign;

% ------------
% Data Storage
% ------------

if ~strcmp(subject,'TEST') % actual run of exp
    [exp,fSaveFile,tSaveFile,~] = expDataSetup(expName,subject,session,condition,restartYN);
else % test run
    fSaveFile = 'TestRun';
    tSaveFile = 'TestRun';
end

% Matlab behaviour and random seed:
set(0,'DefaultFigureWindowStyle','docked')
format shortG
rng('shuffle')
exp.rng = rng;

%----------------
% Prepare Devices
%----------------

% Keyboard:
if binaryType1_YN && length(keysRequired)<2; error('Not enough required keys supplied for a task with binary Type 1 response (key#1,#2).'); end
if binaryType2_YN && length(keysRequired)<4; error('Not enough required keys supplied for a task with binary Type 2 response (key#3,#4).'); end
[key] = prepKeyboard(keysRequired);

% Screen:
if any(strcmp(mode,{'training','test'}))
    skipSyncChecksYN = false;
else
    skipSyncChecksYN = true;
end
[w,hardware] = prepScreen(skipSyncChecksYN);
v2struct(hardware)
exp.hardware = hardware;

% Cursor settings:
HideCursor;

% --------------------------
% Prepare Stimuli and Trials
% --------------------------

% Get stimulus parameters:
p2_stimulusSettings;

% Store all experiment info in temp file and prepare for use:
if ~isempty(VIS); exp.VIS = VIS; v2struct(VIS); end
if ~isempty(AUD); exp.AUD = AUD; v2struct(AUD); end
save(tSaveFile, 'exp');

% Make the stimuli ahead of time (if possible):
if exist('p3_makeStimuli','file')==2; p3_makeStimuli; end

% -------------------------------------------------------------------------
%                        !!!  RUN EXPERIMENT  !!!
% -------------------------------------------------------------------------

% Basic response storage vectors:
if binaryType1_YN; resp = NaN([nTrials,1]); end
if binaryType2_YN; conf = NaN([nTrials,1]); end

% Begin-experiment text:
if exist('beginExpTxt','var') && ~isempty(beginExpTxt); quickPrintText(w,beginExpTxt); end

% Loop through trial sequence:
for trial = 1:nTrials
    
    % Display stimulus:
    p4_playTrial;
    
    % Basic Type 1 response collection:
    if binaryType1_YN
        % instructions:
        if exist('Type1RespTxt','var') && ~isempty(Type1RespTxt); quickPrintText(w,Type1RespTxt,[],[],[],[],[],0.25); end
        % collect response:
        respKey = NaN;
        while ~(respKey == key(1) || respKey == key(2))
            respKey = key_resp(-1);
        end
        % save response:
        switch respKey
            case key(1)
                resp(trial) = -1; % left arrow, save as -1
            case key(2)
                resp(trial) = 1; % right arrow, save as 1
        end
    end
    
    % Basic Type 2 response collection:
    if binaryType2_YN
        % instructions:
        if exist('Type2RespTxt','var') && ~isempty(Type2RespTxt); quickPrintText(w,Type2RespTxt,[],[],[],[],[],0.25); end
        % collect response:
        respKey = NaN;
        while ~(respKey == key(3) || respKey == key(4))
            respKey = key_resp(-1);
        end
        % save response:
        switch respKey
            case key(3)
                conf(trial) = -1; % down arrow, save as -1
            case key(4)
                conf(trial) = 1; % up arrow, save as 1
        end
    end
    
    % Give feedback:
    if exist('p5_giveFeedback','file')==2; p5_giveFeedback; end
    
    % Data storage update:
    if ~isempty(backupFreq) && mod(trial,backupFreq)==0 && trial~=nTrials
        p6_dataStorageInstructions;
        save(tSaveFile,'exp')
    end
    
end

% End-experiment text:
if exist('endExpTxt','var') && ~isempty(endExpTxt); quickPrintText(w,endExpTxt); end

% Execute shutdown:
dataStorageInstructions;
save(fSaveFile,'exp')
delete(tSaveFile)
sca;
ShowCursor;

% Show quick results:
if exist('p7_quickVisResults','file')==2; p7_quickVisResults; end

end
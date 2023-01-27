function [subjectInfo] = readData_getInfo(expName,subject)
% [subjectInfo] = READDATA_GETINFO(expName,subject) will fetch the sID for the
% subject indicated by their initials, of if a subject is not specified,
% the full list of sIDs and initials. It will also complete a check to
% ensure that all recorded data has a subject-ID pairing in the file.
%
% Created by SML July 2016

if nargin < 2
    subject = [];
end

% Find data folder:
dataPath = readData_findDataFolder(expName);

% Get subject initials to ID mapping file:
fileName = [dataPath filesep 'init2sID.mat'];
if exist(fileName,'file') == 2 % file found!
    load(fileName)
else % Create an init to ID mapping file if none exists
    if ~isempty(subject)
        sID = getEntry_init2sID(subject);
        subjectInfo.subject = {subject};
        subjectInfo.sID = [sID];
    else
        disp('It looks like you are the first subject. Let us make a file for you now.')
        subjectInfo.subject = {};
        subjectInfo.sID = [];
    end
    save(fileName,'subjectInfo')
end

% Return if list of inits and sIDs is needed:
if isempty(subject)
    readData_checkInfo(expName,dataPath); % check each subject has been assigned ID
    load(fileName) % reload to current version
    return
end

% Or, get subject ID from initials supplied:
sID = subjectInfo.sID(ismember(subjectInfo.subject,subject));
if isempty(sID) % subject not found! Make an entry
    idx = length(subjectInfo.sID) + 1;
    sID = getEntry_init2sID(subject);
    subjectInfo.subject{idx} = subject;
    subjectInfo.sID(idx) = sID;
    save(fileName,'subjectInfo')
end

end

%%
function readData_checkInfo(expName,dataPath) % check if all Ss have sID

% Find subject initials from folders inside data folder:
d = dir(dataPath);
isfolder = [d.isdir];
subfolders = d(isfolder);
subfolders = subfolders(arrayfun(@(x) x.name(1), subfolders) ~= '.');
init = {subfolders.name};
nSs = length(init);

% Loop through each subject found, creating sIDs for subjects without one
% assigned:
for ii = 1:nSs
    readData_getInfo(expName,init{ii});
end

end

%%
function [sID] = getEntry_init2sID(subject) % get sID for new entry

disp(['The following subject does not have an sID: ' subject])
disp('Let us make an entry!')
sID = str2double(subject(2:end));
if isnan(sID)
    correctYN = 0;
    while correctYN == 0
        ptext = ['\n\nEnter subject ID for ' subject ':'];
        sID = input(ptext);
        resp = input(['\n\nYou have entered ' num2str(sID) '. Is this correct? [1 = yes, 2 = no]\n\n']);
        if resp == 1
            correctYN = 1;
        end
    end
else
    disp('Subject ID automatically extracted!')
end

end
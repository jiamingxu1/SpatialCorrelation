function [subjectInfo] = readData_getSessions(expName,subjectInfo,multTaskTypeYN)
% [subjectInfo] = readData_getSessions(expName,subjectInfo) will check
% inside each subject's raw data directory for the sessions completed. This
% is based on the file's name string instead of the session field of
% exp.info in the saved file. This is because I will typically rename files
% in the event of multiple copies rather than go in and change this value.
% This script will update the subjectInfo structure to list all completed
% sessions.
%
% Created by SML Aug 2016
% Edited by SML Oct 2019 -- included handling of different condtitions/tasks

% Defaults:
if nargin < 3
    multTaskTypeYN = false;
end

% Find data folder:
dataPath = readData_findDataFolder(expName);

% Finding sessions completed from each subject's directory:
nSs = length(subjectInfo.subject);
for ii = 1:nSs % EACH subject
   init = subjectInfo.subject{ii};
   dataPath_full = [dataPath filesep init];
   d = dir(dataPath_full);
   d = d(arrayfun(@(x) x.name(1), d) ~= '.');
   allFiles = {d.name};
   nFiles = length(allFiles);
   all_sessNum = [];
   if multTaskTypeYN; all_sessType = {}; end
   for jj = 1:nFiles % EACH file
       fName = char(allFiles(jj));
       if fName(1:length(init)) == init % IS complete data file
           sessNum = char(regexp(fName,'_S\d*_','match'));
           all_sessNum = [all_sessNum str2double(sessNum(3:end-1))];
           if multTaskTypeYN
               sessType = char(regexp(fName,[expName '_\w*_S'],'match'));
               idx = find(sessType == '_'); 
               idx = (idx(1)+1):(idx(2)-1);
               all_sessType{jj} = sessType(idx);
           end
       end
   end
   subjectInfo.sessions{ii} = all_sessNum;
   if multTaskTypeYN; subjectInfo.task{ii} = all_sessType; end
end

end
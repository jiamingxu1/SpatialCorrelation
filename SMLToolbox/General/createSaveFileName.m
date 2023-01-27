function [saveFile] = createSaveFileName(descriptors,dataPath,extension,delimiter)
% [saveFile] = CREATESAVEFILENAME(descriptors,dataPath) will generate the
% file name based on the directory indicated ('dataPath') and the
% descriptors given ('descriptors'). The descriptors should be strings
% inside a cell array, which will be concatenated in order and separated by
% an underscore unless another delimiter is specified. The optional
% 'extension' will allow you to choose the extension for the file,
% defaulting to '.mat' if none specified.
%
% Created by SML Aug 2016.

% Default (place file in current directory):
if nargin < 4
    delimiter = '_';
    if nargin < 3
        extension = '.mat';
        if nargin < 2
            dataPath = [];
        end
    end
end

% Checks:
assert(iscell(descriptors),'Make sure that descriptors are in a cell array.')
assert(~isempty(descriptors),'Where are your descriptors?')

% Directory for storing data, create if necessary:
if ~isempty(dataPath)
    if ~isdir(dataPath)
        mkdir(dataPath);
    end
end

% Construct file name:
saveFile = strjoin(descriptors,delimiter); % file name alone
saveFile = [dataPath saveFile extension]; % with directory

end
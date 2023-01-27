function [col] = gradCustCol(nCol, gradStart, gradEnd)
% ...
%
% Created by SML Feb 2017

% Defaults
if nargin < 3
    gradEnd = [1 0 1];
    if nargin < 2
        gradStart = [0 0 1];
        if nargin < 10
            nCol = 10;
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

end
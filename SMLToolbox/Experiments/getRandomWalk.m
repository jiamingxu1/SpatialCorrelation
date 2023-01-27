function [randWalk, timeVals] = getRandomWalk(walkSpace, walkSD, nSteps, fs, nDim)
% [randWalk,  timeVals] = GETRANDOMWALK(walkSpace, walkSD, nSteps, fps, nDIM) 
% generates a random sequence, that initialises at 0 and can move in both 
% positive and negative directions (e.g. from the centre of the screen).
%
% INPUTS
% walkSpace: 'position' or 'velocity'
% walkSD: standard deviation of walk (scalar, vector, matrix)
% nSteps: number of total steps in the walk
% fs: sampling frequency, to set the time interval information (default: 60 Hz)
% nDim: number of independent directions in the walk (e.g. horizontal, vetical)
%       or this could be the number of independent trials you want to create.
%
%OUTPUTS
% randWalk: a position-time vector for the walk. 
% timeVals: the time stamps for the random walk. 
%
% Created by SML June 2016, 
% updated by SML Feb 2017 for variable walk SD input

% Defaults:
if nargin < 5
    nDim = 1;
    if nargin < 4
        fs = 60;
        if nargin < 3
            nSteps = 100;
            if nargin < 2
                walkSD = 1;
                if nargin < 1
                    walkSpace = 'position';
                end
            end
        end
    end
end

% Assert checks:
assert(all(walkSpace=='position'|walkSpace=='velocity'),'Choose either position or velocity for walkSpace input.')
[ii,jj] = size(walkSD);
if (jj == 1) || (ii == 1); % If vector or scalar, check dimensions match, convert to column vector if row vector if necessary
    if jj == 1; walkSD = walkSD'; [ii,jj] = size(walkSD); end
    if jj > 1; assert(jj == nDim, 'Walk SD vector dimensions do not match nDim input.'); end
end
if size(walkSD,1) > 1; % If matrix, check the dimensions match other vars specified, transpose if necessary
    if ii ~= (nSteps-1); walkSD = walkSD'; end
    assert((ii == nSteps-1)|(jj == nDim), 'Walk SD matrix dimensions do not match either nSteps or nDim input.')
end

% Sample jumps from Gaussian jump distribution:
mu = zeros(nSteps-1,nDim);
if size(walkSD,1) == 1 % walk is scalar or vector
    sig = repmat(walkSD,nSteps-1,nDim/jj);
end
randWalk = [zeros(1,nDim); normrnd(mu,sig)]; 
% randWalk = [zeros(1,nDim); normrnd(0,walkSD,nSteps-1,nDim)];
timeVals = linspace(0,nSteps/fs,nSteps);

% Form the walk in the desired space using a cumulative sum:
switch walkSpace
    case 'position'
        randWalk = cumsum(randWalk); % Position over time
    case 'velocity'
            % figure; hold on
            % plot(timeVals,randWalk,'k-o')
        randWalk = cumsum(randWalk); % Velocity over time
            % plot(timeVals,randWalk,'-o')
        randWalk = cumtrapz(timeVals,randWalk); % Position over time
            % plot(timeVals,randWalk,'r-o')
            % xlabel('Time (sec)'); ylabel('Velocity (deg/s) or Position (deg)'); legend('velocity samples','velocity walk','position','Location','northwest')
        % Note: computed cumlative integral because distance = velocity * time
end

end
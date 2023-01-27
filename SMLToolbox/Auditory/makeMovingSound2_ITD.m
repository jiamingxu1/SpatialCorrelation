function [s_mov] = makeMovingSound2_ITD(shift,motDir,dur,playYN,freq)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
% INPUTS:
%
% shift:- shift values of the initial and final location. Positive numbers
% will produce a right lateralised sound, negative on the left, and 0 will
% be at the midline.
% motDir:- direction of motion. -1 is leftward, 1 is rightward.
% dur:- duration of the sound.
% playYN:- play the generated sound, yes or no.
% freq:- sampling frequency.
%
% OUTPUTS:
%
% s:- lateralised sound.
%
% Created by SML Feb 2015
% 
% Notes: 
% 1. Seems to be broken for sounds that do not cross the midline.
% 2. Will likely be replaced by a more sophisticated linear interpolation
% algorithm.

% Defaults for demo:
if nargin < 5
    freq = 48000;
    if nargin < 4
        playYN = 1;
        if nargin < 3
            dur = 1;
            if nargin < 2
                motDir = 1;
                if nargin < 1
                    shift = [-20 20];
                end
            end
        end
    end
end

% Get noise stimulus:
s = makeWhiteNoise(1,3,300,16000,dur,freq,0); % unadjusted channel
s = 2*rand(100,1)-1;
slen = length(s); % number of samples

% Check direction of motion matches with start/stop locations:
% error if (1) leftward motion, final postion left of intial, (2) rightward
% motion, final postion right of intial
if (motDir == -1 && shift(1)<shift(2)) || (motDir == 1 && shift(1)>shift(2))
    error('Initial and final shift do not match motion direction.')
end

% Determine the number of filler samples or samples to drop:
fill1 = abs(shift(1));
if prod(sign(shift)) == 1 || shift(2) == 0 % Does not cross midline
    fill2 = 0;
    drop = abs(shift(2));
else % Does cross the midline
    fill2 = abs(shift(2));
    drop = 0;
end

adj_idx = linspace(1,slen-drop,slen-fill1-fill2);
s_adj = interp1(1:slen,s,adj_idx);

figure; hold on
plot(1:slen,s,'bo-')
plot(adj_idx,s_adj,'ro')

s_adj = [2*rand(1,fill1)-1 s_adj 2*rand(1,fill2)-1];

if motDir == -1 % Leftward
    s_mov = [s_adj' s];
elseif motDir == 1 % Rightward
    s_mov = [s s_adj'];
end

if playYN == 1
    player = audioplayer(s,freq);
    play(player);
    WaitSecs(dur+0.5);
end

figure; hold on
plot(s_mov(:,1),'bo-')
plot(s_mov(:,2),'ro-')

end

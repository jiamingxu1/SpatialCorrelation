function [s] = makeStaticSound_ITD(shift,RHS,dur,playYN,freq)
%MAKESTATICSOUND This function generates a lateralised broadband noise
%sound at a specified lateral position, which is defined in terms of a
%shift value. This technique relies on interaural time cues to indicate
%sound position. 
%
% INPUTS:
%
% shift:- delay in the lagging channel in number of samples.
% RHS:- boolean flag for a sound to the right vs left.
% dur:- duration of the sound.
% playYN:- play the generated sound, yes or no.
% freq:- sampling frequency.
% 
% OUTPUTS:
% 
% s:- lateralised sound.
%   
% Created by SML Feb 2015.

% Defaults for demo:
if nargin < 5
    freq = 48000;
    if nargin < 4
        playYN = 1;
        if nargin < 3
            dur = 1;
            if nargin < 2
                RHS = 1;
                if nargin < 1
                   shift = 10; 
                end
            end
        end
    end
end

s = makeWhiteNoise(1,3,300,16000,dur,freq,1); % Get noise stimulus
slen = length(s); % number of samples

if RHS == 1 % Play a sound right of the midline
idx = [shift+1:slen 1:shift];
else % Pay a sound left of the midline
   idx = [slen-shift+1:slen 1:slen-shift]; 
end

s = [s s(idx)]; % stimulus for left and right channels

if playYN == 1
player = audioplayer(s,freq);
play(player);
WaitSecs(dur+0.5);
end

end


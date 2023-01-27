function [s] = makeMovingSound_ITD(shift,motDir,dur,playYN,freq)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
% INPUTS:
%
% shift:- shift values of the initial and final location. Negative numbers
% will produce a right lateralised sound, postive on the left, and 0 will
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
                    shift = [20 20];
                end
            end
        end
    end
end

% Get noise stimulus:
s = makeWhiteNoise(1,3,300,16000,dur,freq,0); % unadjusted channel

% Check direction of motion matches with start/stop locations:
% error if (1) leftward motion, final postion left of intial, (2) rightward
% motion, final postion right of intial
if (motDir == -1 && shift(1)>shift(2)) || (motDir == 1 && shift(1)<shift(2))
    error('Initial and final shift do not match motion direction.')
end

% Determine segment properties:
slen = length(s); % number of samples
nSeg = abs(diff(shift))+1; % number of segments
seglen = floor(slen/nSeg); % samples in each segment
if seglen*nSeg ~= slen
    nCut = slen - seglen*nSeg;
    s = s(1:end-nCut);
    warning('The stimulus was shortened, the new sound duration is:')
    disp(length(s)/freq)
end

% temporal ordering of segments:
if motDir == -1 % LEFTWARD
    segidx = min(shift):1:max(shift);
elseif motDir == 1 %RIGHTWARD
    segidx = max(shift):-1:min(shift);
end

% Make sample specific assignment of segment id:
segidx = repmat(segidx,seglen,1);
segidx = segidx(:);
sampleidx = 1:slen;

% Samples to be deleted:
if motDir*segidx(1) > 0 % Pre-midline segment
    preseg = sampleidx(motDir*segidx > 0);
    preseg = fliplr(preseg);
    kk = abs(shift(1));
    if prod(sign(shift)) == 1 % does not cross the midline
        aa = abs(shift(2));
        cut1 = ((aa:kk-1)*(seglen+1)) + 1;
    else
        cut1 = ((0:kk-1)*(seglen+1)) + 1;
    end
    cut1 = preseg(cut1);
end
if motDir*segidx(end) < 0 % Post-midline segment
    postseg = sampleidx(motDir*segidx < 0);
    kk = abs(shift(2));
    if prod(sign(shift)) == 1 % does not cross the midline
        aa = abs(shift(1));
        cut2 = ((aa:kk-1)*(seglen+1)) + 1;
    else
        cut2 = ((0:kk-1)*(seglen+1)) + 1;
    end
    cut2 = postseg(cut2);
end

% Adjusted channel:
s_adj = s;
s_adj([cut1 cut2]) = [];

% Add padding:
% (both will be true if the sound crosses the midline)
if motDir*segidx(1) > 0 % add padding at beginning
    s_adj = [2*rand(abs(segidx(1)),1)-1; s_adj];
end
if motDir*segidx(end) < 0 % add padding at the end
    s_adj = [s_adj; 2*rand(abs(segidx(end)),1)-1];
end

% Put the unadjusted and adjsuted sound in correct channels:
if motDir == -1 % LEFTWARD
    s = [s_adj s];
elseif motDir == 1 %RIGHTWARD
    s = [s s_adj];
end

if playYN == 1
    player = audioplayer(s,freq);
    play(player);
    WaitSecs(dur+0.5);
end

end
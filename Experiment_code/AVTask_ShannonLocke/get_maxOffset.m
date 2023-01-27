function [maxOffset,minOffset,propSync] = get_maxOffset(v,a,fps)

% Created by SML June 2016

% Checks:
assert(isvector(v),'v must be a vector!')
assert(isvector(a),'a must be a vector!')
if size(v,1) ~= 1;  v = v'; end
if size(a,1) ~= 1;  a = a'; end

% Pre-loop stuff:
nMax = 40; % Half-width of largest temporal kernal in frames
nClicks = NaN(nMax+1,1); % storage vector for number of clicks outside filtered signal

for n = 0:nMax % Each kernal type
    
    % Kernal analysis:
    kernal = [0 ones(1,n)];
    signal = v;
    s1 = conv(signal, kernal); % right lobe
    s2 = fliplr(conv(fliplr(signal), kernal)); % left lobe
    signal = signal + s1(1:end-n) + s2(n+1:end); % temporally smoothed signal
    signal = signal >= 1; % flatten (unecessary but prettier)
    nClicks(n+1) = sum(a(signal==0)); % how many clicks are outside smoothed vis signal?
    
end

minOffset = length(find(nClicks == sum(a))) / fps;
maxOffset = sum(nClicks > 0) / fps; % counting spaces not fence posts so not a problem starting at n=0
propSync = (sum(a) - nClicks(1)) / sum(a); % propotion of synchronous clicks and flashes

end

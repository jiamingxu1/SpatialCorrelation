freq = 48000; % sampling frequency
clickDur = 1/85; % Duration of trial in sec
tone = 700; % tone frequency in Hz
durRamp = 5; % cosine window in ms
nClicks = 10;
nOff = 3;

t = 0:1/freq:clickDur;
s_1 = sin(2*pi*tone*t);
[s_1] = applyCosRamp_ms(s_1,durRamp,freq);
plot(t,s_1)

s_0 = zeros(length(s_1)*nOff,1);
s = repmat([s_1'; s_0],nClicks,1);

player = audioplayer(s,freq);
play(player);
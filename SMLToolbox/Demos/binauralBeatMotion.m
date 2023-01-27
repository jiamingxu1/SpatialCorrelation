freq = 48000; % sampling frequency
dur = 10; % Duration of trial in sec
tone1 = 701; % tone frequency in Hz
tone2 = 700; % tone frequency in Hz
durRamp = 10; % cosine window in ms

t = 1/freq:1/freq:dur;
s1 = sin(2*pi*tone1*t)';
s2 = sin(2*pi*tone2*t)';
s1 = applyCosRamp_ms(s1,durRamp,freq);
s2 = applyCosRamp_ms(s2,durRamp,freq);

% figure; hold on
% plot(t,s1)
% plot(t,s2)

s = [s1 s2];
player = audioplayer(s,freq);
play(player);

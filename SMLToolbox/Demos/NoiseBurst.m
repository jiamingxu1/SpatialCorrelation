freq = 48000; % sampling frequency
clickDur = 1/30; % Duration of trial in sec
lowF = 300;
highF = 16000;
filterType = 3; % Bandpass
plotNoiseYN = 0;
durRamp = 5; % cosine window in ms
nClicks = 1;

s_1 = makeWhiteNoise(1,filterType,lowF,highF,clickDur,freq,plotNoiseYN);
s_1 = applyCosRamp_ms(s_1,durRamp,freq);

s_0 = zeros(length(s_1)*4,1);
s = repmat([s_0; s_1],nClicks,1)

player = audioplayer(s_1,freq);
play(player);
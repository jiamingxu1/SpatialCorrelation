function [] = speakerCalibration(scaleFactor,channel)
%SPEAKERCALIBRSTION plays a 10s long white noise stimulus with a selected
%scale factor. Adjust this scale factor up and down and measure the
%intensity of the resulting sound wave.
%
% SCALEFACTOR: A fraction of maximum intensity. Default = 1.
% CHANNEL: Speaker channel to play sound. Enter two value vector with 1's 
% for the active channel. Default = both.
%
% Created by SML August 2015.

if nargin < 2
    channel = [1 1];
    if nargin < 1
        scaleFactor = 1; % range 0 to 1
    end
end

% Make stimulus:
s = makeWhiteNoise(1,3,200,10000,10,48000,0);
s = applyCosRamp_ms(s,5,48000);
s = rescaleSound(s,2,0);
s = scaleFactor * s;

% Put into channels:
s_play = zeros(length(s),2);
for ii = 1:2
    if channel(ii) == 1
       s_play(:,ii) = s;
    end
end

plot(s_play)

% Play sound:
player = audioplayer(s_play,48000);
play(player);
WaitSecs(12);

end


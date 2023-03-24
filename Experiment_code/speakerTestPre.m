% make white noise
AudInfo.fs                  = 44100;
audioSamples                = linspace(1,AudInfo.fs,AudInfo.fs);
standardFrequency_gwn       = 10;
AudInfo.adaptationDuration  = 0.1; %0.05 %the burst of sound will be displayed for 40 milliseconds
duration_gwn                = length(audioSamples)*AudInfo.adaptationDuration;
timeline_gwn                = linspace(1,duration_gwn,duration_gwn);
sineWindow_gwn              = sin(standardFrequency_gwn/2*2*pi*timeline_gwn/AudInfo.fs); 
carrierSound_gwn            = randn(1, max(timeline_gwn));
AudInfo.intensity_GWN       = 15;
AudInfo.GaussianWhiteNoise  = [zeros(size(carrierSound_gwn));...
                                 AudInfo.intensity_GWN.*sineWindow_gwn.*carrierSound_gwn]; 
% open speakers
addpath(genpath('/e/3.3/p3/hong/Desktop/Project5/Psychtoolbox'));
PsychDefaultSetup(2);
InitializePsychSound
devices = PsychPortAudio('GetDevices');
our_device=devices(3).DeviceIndex;

% open arduino
Arduino = serial('/dev/cu.usbmodemFD131','BaudRate',9600); 
fopen(Arduino);
a=[1 2 3 4 5];
for i = 1:i
    fprintf(Arduino,'%d',sprintf('%d',a(i),1));
end


% play sound
pahandle = PsychPortAudio('Open', our_device, [], [], [], 2);%open device
PsychPortAudio('FillBuffer',pahandle, AudInfo.GaussianWhiteNoise);
PsychPortAudio('Start',pahandle,1,0,0);
PsychPortAudio('Stop',pahandle);

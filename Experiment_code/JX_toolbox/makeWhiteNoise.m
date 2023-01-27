function GWN = makeWhiteNoise(display)

switch display
    case 1 % meyer 957      
    case 2 % my laptop
      
end

AudInfo.fs                      = 44100; 
audioSamples                    = linspace(1,AudInfo.fs,AudInfo.fs);
standardFrequency_gwn           = 10;
AudInfo.adaptationDuration      = 0.1; %0.05 %the burst of sound will be displayed for 40 milliseconds
duration_gwn                    = length(audioSamples)*AudInfo.adaptationDuration; %sampling freq (how many samples in 1s)
timeline_gwn                    = linspace(1,duration_gwn,duration_gwn); 
sineWindow_gwn                  = sin(standardFrequency_gwn/2*2*pi*timeline_gwn/AudInfo.fs); 
carrierSound_gwn                = randn(1, max(timeline_gwn)); %gaussian noise
AudInfo.intensity_gwn           = 15;
GWN                             = [zeros(size(carrierSound_gwn));...
                                 AudInfo.intensity_gwn.*sineWindow_gwn.*carrierSound_gwn]; 
end


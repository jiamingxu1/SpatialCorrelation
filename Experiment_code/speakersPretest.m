%% Test all speakers to make sure everything works
addpath(genpath('/e/3.3/p3/hong/Desktop/Project5/Psychtoolbox'));

% make auditory stimuli 
AudInfo.fs                           = 44100;
AudInfo.stimDura                     = 0.1; % ExpInfo.stimFrame * ScreenInfo.ifi; %s, the duration of auditory stimulus
AudInfo.tf                           = 500;
AudInfo.beepLengthSecs               = AudInfo.stimDura;
beep                                 = MakeBeep(AudInfo.tf, AudInfo.beepLengthSecs, AudInfo.fs);
AudInfo.Beep                         = [beep; beep];

% initialize ptb
PsychDefaultSetup(2);
InitializePsychSound
devices = PsychPortAudio('GetDevices');
our_device=devices(3).DeviceIndex;
pahandle = PsychPortAudio('Open', our_device, [], [], [], 2);
PsychPortAudio('FillBuffer',pahandle, AudInfo.Beep);    

% initialise serial object
Arduino = serial('/dev/cu.usbmodemFD131','BaudRate',9600); 
% open for usage
fopen(Arduino);
% ----------------For troubleshooting Arduino-----------------
% fprintf(Arduino,'<0:1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16>');
% fprintf(Arduino,'<1:16>');
% fscanf(Arduino) 
% ------------------------------------------------------------

%% test all speakers
left = 1:1:16;
right = 16:-1:1;
audTrain = [left; right];
for i=1:2
    for j=1:16
    input_on = ['<',num2str(1),':',num2str(audTrain(i,j)),'>'];
    fprintf(Arduino,input_on);
    %draw (buffer)
    %flip here (stimulus onset timing)
    %flip (offset)
    PsychPortAudio('Start',pahandle,1,0,0);
    WaitSecs(0.2)
    input_off = ['<',num2str(0),':',num2str(audTrain(i,j)),'>'];
    fprintf(Arduino,input_off);   
    PsychPortAudio('Stop',pahandle);
    WaitSecs(0.15)
    end
    WaitSecs(0.5)
end



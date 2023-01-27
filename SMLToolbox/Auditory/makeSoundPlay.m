function makeSoundPlay(pamaster)

% ----------------
% Moving stimulus:

s = makeWhiteNoise(filterType,lowF,highF,dur,freq,plotNoiseYN); % Broadband white noise
moving = 0.5*[s; s]+1; % Duplicate left and right channels

% Open slave sound device, and feed it a buffer containing the unmodulated
% moving stimulus component.
paMoving = PsychPortAudio('OpenSlave', pamaster, 1); % virtual device 1
paMovBuf = PsychPortAudio('CreateBuffer', [], moving);
PsychPortAudio('UseSchedule', paMoving, 1, nMovSounds); % Prepare a schedule
PsychPortAudio('AddToSchedule', paMoving, paMovBuf) % , [], [], [], [], 2); % Fill schedule

% ---------------------
% Amplitude modulation:

linAM = [];

for speaker = [1 -1] % Left and Right

gradILD = speaker *dirMotion * (pMaxVolDif/nSamples); % Gradient of AM function
initILD = pCoh - (0.5 * speaker * dirMotion * pMaxVolDif); % Initial Vol
linAM = [linAM; gradILD * (1:nSamples) + initILD]; % AM function for L & R channels

end

% Open another slave sound device, and feed it a buffer containing the AM
% function.
paAM = PsychPortAudio('OpenSlave', pamaster, 32); % virtual device 2
paAMBuf = PsychPortAudio('CreateBuffer', [], linAM);
PsychPortAudio('UseSchedule', paAM, 1, 1); % Prepare a schedule
PsychPortAudio('AddToSchedule', paAM, paAMBuf) % , [], [], [], [], 2); % Fill schedule

% --------------------
% Stationary stimulus:

s = makeWhiteNoise(filterType,lowF,highF,dur,freq,0); % Broadband white noise
stat = [s; s]; % Duplicate left and right channels

% Open slave sound device, and feed it a buffer containing the unmodulated
% moving stimulus component.
paStat = PsychPortAudio('OpenSlave', pamaster, 1); % virtual device 3
paStatBuf = PsychPortAudio('CreateBuffer', [], stat);
PsychPortAudio('UseSchedule', paStat, 1, 1); % Prepare a schedule
PsychPortAudio('AddToSchedule', paStat, paStatBuf) % , [], [], [], [], 2); % Fill schedule

PsychPortAudio('Volume', paStat, 1-pCoh);

%-------------
% Play Stimuli
%-------------

% tt = GetSecs;
% tStart1 = PsychPortAudio('Start', paMoving, 0, tt + 3, 1);
% tStart2 = PsychPortAudio('Start', paAM, 0, tt + 3, 1);
% tStart3 = PsychPortAudio('Start', paStat, 0, tt + 3, 1);
% WaitSecs(10)


%------
% Notes
%------

% If you need to modulate output volume over time, you can also attach an
% additional slave device whose opMode is set to act as an AMmodulator to a master
% or slave device, see help for 'OpenSlave'. Such a slave device will not output
% sound itself, but use the data stored in its playback buffers to modulate the
% amplitude of its parent slave, or of the summed signal of all previously
% attached slaves for a master over time. Example: You create a master device,
% then 'OpenSlave' three regular slave devices, then 'OpenSlave' a AMmodulator
% slave device. During playback, the sound signals of the three regular slaves
% will be mixed together. The combined signal will be multiplied by the per-sample
% volume values provided by the AMmodulator slave device, thereby modulating the
% amplitude or ''acoustic envelope'' of the mixed signals. The resulting signal
% will be played by the master device. If you'd attach more regular slave devices
% after the AMmodulator, their signal would not get modulated, but simply added to
% the modulated signal of the first three devices.
% You can also modulate only the signals of a specific slave device, by attaching
% the modulator to that slave device in the 'OpenSlave' call. You'd simply pass
% the handle of the slave that should be modulated to 'OpenSlave', instead of the
% handle of a master device.

% The slave-only mode flag 32 (kPortAudioIsAMModulator) defines a slave device not
% as a source of audio data, but as a source of amplitude modulation (AM) envelope
% data. Its samples don't create sound, but gain-modulate the sound of other
% slaves attached to the master to allow precisely timed AM modulation. See the
% help for PsychPortAudio('Volume') for more details about AM.

% soundA = MakeBeep(100, 6.0, freq);
% soundB = MakeBeep(500, 6.0, freq);
% soundB = rand(size(soundB));
% sound1 = [soundA; soundB];

% % If you are concatenating multiple sounds, do this iteratively:
% buffer = []
% buffer(end+1) = PsychPortAudio('CreateBuffer', [], audiodata);

function [ stim, point ] = makeILDnoise(direction, velocity, Fs)

 

% function [ p ] = makeILDsound(direction, startloc, extent, plotyn)

 

% This function will make but not  play a lateralised sound which moves in one direction

% stimulus is of a fixed duration

% duration must be divisible by the extent otherwise it is distorted

 

% Inputs

 

% direction:    either 1 = 'leftward' or  0 = 'rightward' movement

% leftpoint:    leftmost location

% rightpoint:   rightmost location

% plotyn:       if 'y' will plot stimulus

 

% Outputs

 

% stim:         the stimulus (2 row vectors for psychportaudio) 

% p:            details of this stimlus (path, freq etc)

 

% written by eom 30/04/14

% /jl 30/9/14

 

% defaults('plotyn', 0, 'direction', 1 , 'Fs', 384000);

 

%% Paramter set up

 

p.range = 180;

p.sfreq = Fs;

p.srate = 1000/p.sfreq * 1000;

p.totaldur = 1; % in seconds

 

% space = velocity;

% lspace = -1*velocity/2;

% rspace = velocity/2;

 

 

% Create flag for positon (far left to far right in ild shift)

% Cut out desired portion from start and end of arc to be presented

point(:,1) = [p.range:-1:(p.range - (velocity-1))]';

point(:,2) = (1:velocity)'; 

 

% now shift it to the middle (90)

shiftnum = p.range/2 -velocity/2;

point(:,1) = point(:,1) - shiftnum;

point(:,2) = point(:,2) + shiftnum;

 

 

% Choose which direction to present

if direction

else

    point = flipud(point);

end

 

p.numPoints = size(point,1);

p.stimdur = (p.totaldur/p.numPoints);

p.path = point;

 

%

% Make stimulus

%

 

lstim = []; rstim = [];

% [~,ofilt] = mkBees(p.stimdur,[],[],[],[],p.sfreq);

% pre-generate the filter envelope. 

% [~,ofilt] = mkBees(1/180,[],[],[],[],p.sfreq);

 

%with random onset 

randon = randi(1);

if rand > 0.5

    randon = -1*randon;

end

% randon

point(:,1) = point(:,1) - randon-1;

point(:,2) = point(:,2) + randon;

 

% calculate ILD loudness factor, dividing the IACC into ±90°. 

ildfact = point/180;

 
for spidx = 1:p.numPoints    
    [lt,rt] = s_makesound(p, ildfact(spidx,:));
    lstim = [lstim;lt];
    rstim = [rstim;rt];    
end
 
% ramp onset and offset
lstim = rcos(lstim,3);
rstim = rcos(rstim,3);
% mf = max(max([lstim rstim]));
% lstim = lstim/mf;
% rstim = rstim/mf;
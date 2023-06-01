% This is the main experiment. We present A and V trains of 5 simultaneously,
% with fixed, repetitive timing. We vary the spatial locations of A and V
% within a spatial window of 5, such that the corr between AV trains range
% from [-1,1]. The task is first localize the centroid of A or V, and then
% report unity judgment. 

%% Enter subject's name, setup screen 
clear all; close all; clc; rng('shuffle');
addpath(genpath('/e/3.3/p3/hong/Desktop/Project5/Psychtoolbox'));

display = 1; % 1:testing room; 2:my laptop
ExpInfo.subjID = [];
while isempty(ExpInfo.subjID) == 1
    try ExpInfo.subjID = input('Please enter participant ID#: ') ; %'s'
    catch
    end
end

%enter session number
ExpInfo.session = [];
while isempty(ExpInfo.session) == 1
    try ExpInfo.session = input('Please enter the session#: ') ; %'s'
    catch
    end
end

ScreenInfo = setup_screen3(display);
kb.escKey = KbName('ESCAPE');

%% initialise serial object
Arduino = serial('/dev/cu.usbmodemFD131','BaudRate',9600); 
% open for usage
fopen(Arduino);

%% Open speakers and create sound stimuli 
PsychDefaultSetup(2);
% get correct sound card
InitializePsychSound
devices = PsychPortAudio('GetDevices');
our_device=devices(3).DeviceIndex;

%% make auditory stimuli (beep)
AudInfo.fs                           = 44100;
AudInfo.stimDura                     = 0.1; % ExpInfo.stimFrame * ScreenInfo.ifi; %s, the duration of auditory stimulus
AudInfo.tf                           = 500;
AudInfo.beepLengthSecs               = AudInfo.stimDura;
beep                                 = MakeBeep(AudInfo.tf, AudInfo.beepLengthSecs, AudInfo.fs);
AudInfo.Beep                         = [beep; beep];
pahandle = PsychPortAudio('Open', our_device, [], [], [], 2); %open device

%% make visual stimuli (gaussian blob)
%scaling
VSinfo.standard                      = 0.4;%0.2; % a ratio between 0 to 1 to be multipled by 255
pblack                               = 1/8; % set contrast to 1*1/8 for the "black" background, so it's not too dark and the projector doesn't complain
%define visual stimuli
VSinfo.Distance                      = linspace(26.7358,26.7358,16); %in deg
VSinfo.numLocs                       = length(VSinfo.Distance);
VSinfo.numFrames                     = 6;
%VSinfo.duration                      = VSinfo.numFrames * ifi;%s
VSinfo.width                         = 201; %(pixel) Increasing this value will make the cloud more blurry (arbituary value)
VSinfo.boxSize                       = 101; %This is the box size for each cloud (arbituary value)
%set the parameters for the visual stimuli
VSinfo.blackBackground               = pblack * ones(ScreenInfo.xaxis,ScreenInfo.yaxis);
VSinfo.transCanvas                   = zeros(ScreenInfo.xaxis,ScreenInfo.yaxis);
x                                    = 1:1:VSinfo.boxSize; y = x;
VSinfo.x                             = x; VSinfo.y = y;
[X,Y]                                = meshgrid(x,y);
VSinfo.cloud1d                       = mvnpdf([X(:) Y(:)],[median(x) median(y)],...
[VSinfo.width 0; 0 VSinfo.width]);
pscale                               = (1-pblack)/max(VSinfo.cloud1d); % the max contrast of the blob adds the background contrast should <= 1
VSinfo.cloud1d                         = VSinfo.cloud1d .* pscale;
VSinfo.Cloud                         = VSinfo.standard.*reshape(VSinfo.cloud1d,length(x),length(y));
VSinfo.blk_texture                   = Screen('MakeTexture', windowPtr, VSinfo.blackBackground,[],[],[],2);

    
%% define the experiment information
% ExpInfo.numTrials         = 1;%for each AV pair
% ExpInfo.AVpairs_allComb   = combvec(1:length(ExpInfo.matchedAloc), 1:VSinfo.numLocs,...
%                                 1:length(VSinfo.temporalOffset)); 
%                             %1st row: A loc, 2nd row: V loc, 3rd row: t_A - t_V
% ExpInfo.numAVpairs        = size(ExpInfo.AVpairs_allComb, 2); %24 possible pairs 
 ExpInfo.numTotalTrials    = 12;%ExpInfo.numTrials * ExpInfo.numAVpairs;
% ExpInfo.AVpairs_order     = Shuffle(1:ExpInfo.numAVpairs);
%Given the order of trial types, find the corresponding V and the A locations
VSinfo.arrangedLocs_deg   = VSinfo.Distance(ExpInfo.AVpairs_allComb(2,ExpInfo.AVpairs_order));
VSinfo.arrangedLocs_cm    = round(tan(deg2rad(VSinfo.arrangedLocs_deg)).*ExpInfo.sittingDistance,2);


ExpInfo.bool_unityReport  = ones(1,ExpInfo.numTotalTrials);%1: insert unity judgment
%initialize a structure that stores all the responses and response time
[Response.localization, Response.RT1, Response.unity, Response.RT2] = ...
    deal(NaN(1,ExpInfo.numTotalTrials));  


%% Define experiment information

% Create auditory and visual trains with fixed corrs. Shuffled AV sequences
% with randomized corr values are saved in Atrain and Vtrain
nEvents = 5;
allSeqs = perms(1:nEvents);
nSeq = size(allSeqs,1);

% AV corr matrix
Corr = NaN(nSeq, nSeq);
for ii = 1:nSeq
    for jj = 1:nSeq
        Corr(ii,jj) = corr(allSeqs(ii,:)',allSeqs(jj,:)');
    end
end
CorrReshape = reshape(Corr, 1,[]);
figure; histogram(CorrReshape,20)
    
% construct two arrays with A,V sequences with fixed corr
CorrVal = -1:0.1:1;
nCorr = length(CorrVal); 
nCorrRep = 120; % number of sequences for each correlation
CorrSortedA = cell(nCorrRep,nCorr); %120*21
CorrSortedV = cell(nCorrRep,nCorr);
idxA = NaN(nCorrRep,nCorr); %120*21
idxV = NaN(nCorrRep,nCorr);
for i = 1:nCorr
    [idxA_temp,idxV_temp] = find(Corr > CorrVal(i)-1e-5 &...
        Corr < CorrVal(i)+1e-5); 
    idx_subset = randsample(length(idxA_temp),nCorrRep);
    idxA(:,i) = idxA_temp(idx_subset);
    idxV(:,i) = idxV_temp(idx_subset); 
    % idxA,V correspond to the row numbers in allSeqs. Next, fetch the sequences 
    % from allSeqs and put them into CorrSortedA and CorrSortedV
    for j = 1:nCorrRep
        CorrSortedA{j,i} = allSeqs(idxA(j,i),1:end);
        CorrSortedV{j,i} = allSeqs(idxV(j,i),1:end);
    end
end

% reshape and shuffle
Atrain_temp = reshape(CorrSortedA, [], 1); %2520*1
Vtrain_temp = reshape(CorrSortedV, [], 1); %2520*1
randidx     = randperm(2520);
Atrain      = Atrain_temp(randidx);
Vtrain      = Vtrain_temp(randidx);

% check corr
CorrAV = NaN(2520,1);
for i = 1:2520
    CorrAV(i) = corr(Atrain{i}',Vtrain{i}');
end



%%
fclose(Arduino)
delete(Arduino)

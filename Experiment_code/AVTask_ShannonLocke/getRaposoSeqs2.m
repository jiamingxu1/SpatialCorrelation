% This code generates sequences that would be analagous to those in Raposo
% et al. (2012). Events are 10ms long, and gaps either 60 or 120ms long.
% There is a minimum delay of 20ms between auditory and visual events in
% the asynchronous condition.

function [rate, all_maxOffset, all_propSync, eV, eA] = getRaposoSeqs2(N)

ISI = [6 12]; % Interstimulus intevals in frames
eventDur = 1; % event duration in frames
trialDur = 100; % Number of frames (1 sec duration)
enforcedDelay = 2; % Number of frames btwn A & V events in frames
maxGaps = ceil(trialDur / (min(ISI) + eventDur)); % maximum number of gaps

rate = nan(N,1);
all_maxOffset = nan(N,1);
all_propSync = nan(N,1);

for n =1:N
    seedSeq = randi(2,[1,maxGaps]); % fix rate by setting ratio of S & L
    idx = cumsum(ISI(seedSeq) + eventDur) <= 100; % how many ISIs?
    seedSeq = [seedSeq(idx) seedSeq(sum(idx)+1)]; % Remove any longer than trial duration
    ok = 0;
    while ok == 0 % Loop until a sequence that meets all requirements is found
        eA = []; % auditory sequence
        eV = []; % visual sequence
        seqV = ShuffleRC(seedSeq,2); % Shuffle to get V sequence
        seqA = ShuffleRC(seedSeq,2); % Separate shuffle for A, because asynch.
        totalDur = 0;
        while totalDur < (trialDur - enforcedDelay) % Build event sequences 
            eV = [eV 1 zeros(1,ISI(seqV(1)))];
            eA = [eA 1 zeros(1,ISI(seqA(1)))];
            seqV(1) = [];
            seqA(1) = [];
            totalDur = min(length(eA),length(eV));
        end
        firstPlacement = randi(2);
        if firstPlacement == 1 % Make first event in visual stream
            eV = [eV zeros(1,enforcedDelay)];
            eA = [zeros(1,enforcedDelay) eA];
        else % Make first event in auditory stream
            eV = [zeros(1,enforcedDelay) eV];
            eA = [eA zeros(1,enforcedDelay)];
        end
        eV = eV(1:trialDur); % Delete any additional frames
        eA = eA(1:trialDur);
        [maxOffset,minOffset,propSync] = get_maxOffset(eV,eA,trialDur);
        if minOffset >= 0.02 % accept only if minimum delay is at least 0.2s
            ok = 1;
        end
    end
    rate(n) = mean(sum(eV),sum(eA));
    all_maxOffset(n) = maxOffset;
    all_propSync(n) = propSync;
end

end
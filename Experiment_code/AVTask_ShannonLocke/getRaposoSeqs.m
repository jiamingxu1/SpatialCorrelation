% This code generates sequences that would be analagous to those in Raposo
% et al. (2012). Events are 10ms long, and gaps either 60 or 120ms long.
% There is a minimum delay of 20ms between auditory and visual events in
% the asynchronous condition.

set(0,'DefaultFigureWindowStyle','docked')
N = 1000; % number of seq to be made
ISI = [6 12]; % Interstimulus intevals in frames
eventDur = 1; % event duration in frames
trialDur = 100; % Number of frames (1 sec duration)
enforcedDelay = 2; % Number of frames btwn A & V events in frames
maxGaps = ceil(trialDur / (min(ISI) + eventDur)); % maximum number of gaps

all_rate = nan(N,1);
all_minOffset = nan(N,1);
all_maxOffset = nan(N,1);
all_ssr = nan(N,1);
all_msr = nan(N,1);

for n =1:N
    seedSeq = randi(2,[1,maxGaps]); % fix rate by setting ratio of S & L
    idx = cumsum(ISI(seedSeq) + eventDur) <= 100;
    seedSeq = [seedSeq(idx) seedSeq(sum(idx)+1)]; % Remove any longer than trial duration
    ok = 0;
    while ok == 0
        eA = []; % auditory sequence
        eV = []; % visual sequence
        totalDur = 0;
        seqV = ShuffleRC(seedSeq,2); % Shuffle to get V sequence
        seqA = ShuffleRC(seedSeq,2); % Separate shuffle for A, because asynch.
        while totalDur < (trialDur - enforcedDelay)
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
        [maxOffset,minOffset,~] = get_maxOffset(eV,eA,trialDur);
%         figure; hold on
%         stem(1.2*eA); stem(eV,'r')
%         disp(minOffset)
%         disp(maxOffset)
        if minOffset >= 0.02 % accept only if minimum delay is at least 0.2s
            ok = 1;
            [ssr,msr] = get_seqSimilarity(eV,eA,trialDur);
        end
    end
    all_rate(n) = mean(sum(eV),sum(eA));
    all_minOffset(n) = minOffset;
    all_maxOffset(n) = maxOffset;
    all_ssr(n) = ssr;
    all_msr(n) = msr;
end

disp([all_rate all_minOffset all_maxOffset all_ssr all_msr])
figure; hist(all_ssr)
figure; hist(all_msr)
% let's look at the sequences:

% v = all_frameType;
% a = all_ear;
% rm = resMat;
% 
% v = [v all_frameType];
% a = [a all_ear];
% rm = [rm; resMat];

% Stop being lazy and do a fucking convolution already!

nSeq = size(v,2);
nMax = 40; % Half-width of temporal kernal
Fs = 60; % Frames per second
nClicks = NaN(nMax+1,nSeq); 
peakCorr = NaN(nSeq,1); 
maxCorr = NaN(nSeq,1); 

for n = 0:nMax % Each kernal type
    for seq = 1:nSeq % EACH sequence
        
        % Kernal analysis:
        kernal = [0 ones(1,n)];
        signal = v(:,seq)';
        s1 = conv(signal, kernal);
        s2 = fliplr(conv(fliplr(signal), kernal));
        s = signal + s1(1:end-n) + s2(n+1:end);
        s = s >= 1;
        compA = a(:,seq)';
        nClicks(n+1,seq) = sum(compA(s==0));
        % disp([signal' s'])
        % plot(s,'-r'); hold on; stem(signal);
        
        % CCG analysis:
        if n == 0
        ts1 = v(:,seq);
        ts2 = a(:,seq);
        [r,lag] = xcorr(ts2,ts1,'coeff'); % Compute CCG
        lag = lag/Fs; % Put in terms of seconds
        peakCorrAt = lag(r==max(abs(r))); % location of peak correlation
        peakCorrAt = peakCorrAt(abs(peakCorrAt)==min(abs(peakCorrAt))); % select smallest duration peak correlation
        peakCorr(seq,1) = peakCorrAt(1);
        mc = r(abs(lag) <= 0.15);
        mc = mc(mc==max(abs(mc)));
        maxCorr(seq,1) = mc(1);
        % plot(lag,r,'Linewidth',2); legend(['peak at: ' num2str(roundn(peakCorrAt,3)) ' sec']); xlabel('Delay (sec)'); ylabel('Correlation')

        end
    end
end
disp(nClicks) 

rate = rm(:,1);
tempConflictYN = rm(:,2);
response = rm(:,3);
maxOffset = (sum(nClicks > 0))';

T = table(rate, tempConflictYN, maxOffset, peakCorr, maxCorr, response);
filesave = '/Users/shannonlocke/GoogleDrive/Library/Experiments/AudiovisualRateDiscrimination/DataAnalysis/RateJNDinR/data_raw_rateJND/controlExpData.txt';
writetable(T,filesave,'Delimiter',' ')



% % And, nope...
% 
% for s = 1:size(v,2) % EACH sequence
%     for t = 1:size(v,1) % EACH trial
%         if v(t,s) == 1 % An event!
%             try
%                 v(t-1,s) = 1; % recode previous as event
%             end
%             try
%                 v(t+1,s) = 1;% recode previous as event
%             end
%         end
%     end
% end
% x = a * (1 - v)
% 
% % Eh, I don't think what's below is really all that great...
% 
% f = size(v,1);
% n = 1;
% i = 1; % counter
% while n > 1
%     if idx == 1
%         idx = find(v==1);
%     end
%     idx_prev = idx - 1; % One before
%     idx_prev(mod(idx_prev, f) == f-1) = [];
%     idx_next = idx + 1; % One after
%     idx_next(mod(idx_next, f) == 1) = [];
%     if idx == 1
%         r = find(v==1);
%     end
% end
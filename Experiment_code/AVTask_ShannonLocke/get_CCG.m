function [r, lag] = get_CCG(ts1, ts2, Fs)

% Compute:
[r,lag] = xcorr(ts2,ts1,'coeff'); % Compute CCG
lag = lag/Fs; % Put in terms of seconds
% peakCorrAt = lag(r==max(abs(r))); % location of peak correlation

% Visualise:
% stem(lag,r)
% legend(['peak at: ' num2str(roundn(peakCorrAt,3)) ' sec'])
% xlabel('Delay (sec)')
% ylabel('Correlation')
         
end
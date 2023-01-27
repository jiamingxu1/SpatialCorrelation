% create some signals
duration=2; % in s
fs=1000;
nsamp=fs*duration;
n_signals=50;
signals=randn(n_signals,nsamp,2);

% make the first 25 signals perfectly correlated
signals(1:n_signals/2,:,2)=signals(1:n_signals/2,:,1);

% create a vector of responses (for simplicity response is set to 1 for correlated signals, and 0 otherwise)
resp=ones(25,1);
resp(26:50)=0;

for sn=1:n_signals
    xc_signals(sn,:)=xcorr(signals(sn,:,1),signals(sn,:,2),'coeff');
end

% create smoothing kernel
smooth_w=.04; % width of the smoothing windows in s
t_win=linspace(-duration,duration,fs*duration*2-1);
g_win=normpdf(t_win,0,smooth_w); g_win=g_win./sum(g_win);

% calculate classification image
ci=mean(xc_signals(resp==1,:))-mean(xc_signals(resp==0,:));
ci=conv(ci,g_win,'same');

plot(t_win, ci)
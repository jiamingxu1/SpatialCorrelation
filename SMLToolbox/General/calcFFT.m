function [f,amp,phase] = calcFFT(X,sf,plotYN)
% [f,amp,phase] = CALCFFT(X,sf,plotYN) is a function that returns the
% single-side spectrogram and phase values of all input signals supplied.
%
% INPUTS
% X: signal/signals. If there is more than 1 signal, X should be a matrix
% where each column is a different signal. Note that this requires the
% signals to all be of the same length.
% sf: sampling frequency of the signal.
% plotYN: toggle for the plot of signal amplitude and phase (default = no).
%
% OUTPUTS
% f: the frequency axis.
% amp: the amplitude in each frequency band.
% phase: the phase of each frequency band.
%
% Created by SML Aug 2016

% Defaults:
if nargin < 3
    plotYN = 0;
end

% Get properties of time series X:
N = size(X,1); % Number of samples
if N == 1 % IF column vector, transpose
    X = X'; 
   N = size(X,1);
   
end
df = sf/N; % Frequency step size (i.e. frequency resolution)
f = df * (0:(N/2)); % frequency values

% Compute Fast Fourier Transform of X:
Y = fft(X);

% Rearrange output to be just the DC component and positive lobe:
if mod(N,2) == 0 % N is even
   Y = Y(1:(N/2+1),:,:);
else
   Y = Y(1:((N-1)/2+1),:);
end

% Get amplitude information:
amp = abs(Y/N); % normalise
amp(2:end-1,:,:) = 2*amp(2:end-1,:,:); % redistribute power from negative lobe
   
% Get phase information:
phase = angle(Y); % unwrap(angle(Y));

% Plot?
if plotYN == 1
    nPlots = size(X,2);
    for ii = 1:(nPlots);
    figure; 
    subplot(2,1,1); hold on; stem(f,amp(:,ii)) % amplitude
    xlabel('Frequency (Hz)'); ylabel('Amplitude'); title(['signal: ' num2str(ii)]);
    subplot(2,1,2); hold on; stem(f,phase(:,ii)) % phase
    xlabel('Frequency (Hz)'); ylabel('Phase (radians)');
    end
end

end
function [s] = applyCosRamp_samples(sig,n)
%APPLYCOSRAMP_SAMPLES This function applies a hanning window cosine ramp at 
% the first and last n samples of the signal. Note that this code was
% adjusted so that the first and last signal are set to 0.
%
%   INPUTS:
%   sig:- signal to be adjusted.
%   n:- number of samples in ramp at onset/offset.
%
%   OUTPUTS:
%   s:- ramped signal.
%
% Created by SML Aug 2016

assert(isvector(sig),'Please input a vector for sig.')
assert((n>0)&(mod(n,1)==0),'Check that n is a positive integer.')

% Hanning window cosine ramp:
win = [0; hanning((n-1)*2); 0];

% If necessary, rotate win vector to match signal:
[~,c_sig]=size(sig);
[~,c_win]=size(win);
if c_sig ~= c_win
   win = win'; 
end

% Onset and offset components:
win_on = win(1:n);
win_off = win(n+1:end);

% Apply ramp to signal:
s = sig;
s(1:n) = s(1:n) .* win_on;
s(end-n+1:end) = s(end-n+1:end) .* win_off;

end
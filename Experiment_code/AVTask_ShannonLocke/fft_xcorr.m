% How to pad vectors when doing a cross-correlation using fft that gives
% IDENTICAL output to xcorr?

% https://www.mathworks.com/matlabcentral/newsreader/view_thread/165733 
% tells me that to get the same vector length output I must pad the vectors
% s.t. their length is n1+n2-1. Below I'm using the "chuck it at the end"
% strategy in the final post. The vector is the same length, but the output
% isn't the same...

n = 10
A = rand(1,n)
B = rand(1,n)

r = xcorr(A,B,'coeff')

AA = fft([A zeros(1,n-1)])
BB = fft([B zeros(1,n-1)])

rr = ifft(AA.*BB)

figure; hold on
plot(r,'r')
plot(real(rr),'b')
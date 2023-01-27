function [s_adj] = rescaleSound(s,s_range,plotYN)
%RESCALESOUND This function will rescale a sound so that the mean is 0, and
%and set the range of intensities such that 99.998% of samples are within the 
%specified range. The code is useful for adjusting the volume of a stimulus,
%or rescaling after combining multiple sounds together.
%
% INPUTS:
% 
% s:- this is the sound to be modified.
% s_range:- desired range of intensities, can be a vector of size two if 
% each channel has a different range (default is 2).
% plotYN:- plot the unadjusted and adjusted sound (default is no).
%
% OUTPUTS:
%
% s_adj:- the adjusted sound.
%
% Created by SML Feb 2015.

if nargin < 3
    plotYN = 0;
    if nargin < 2
        s_range = 2; % range -1 to 1
    end
end

% General checks:
[i,j] = size(s);
if i == 1 || j == 1
    channels = 1;
    if j > 1
        s = s';
    end
elseif i == 2 || j == 2
    channels = 2;
    if j > 2
        s = s';
    end
    if length(s_range) == 1
        s_range = [s_range s_range];
    end
else
    error('Check the input sound. Must have 1 or 2 channels.')
end

s_adj = zeros(size(s));

for ii = 1:channels

shift = diff([0 mean(s(:,ii))]);
sdiff = prctile(s(:,ii),99.9999)-prctile(s(:,ii),0.0001);
rescale = s_range/sdiff;

s_adj(:,ii) = s(:,ii) + shift;
s_adj(:,ii) = rescale(ii) * s_adj(:,ii);

if plotYN == 1
    figure; hold on
    slen = length(s(:,ii));
    plot(1:slen,s(:,ii),'k-')
    plot(1:slen,s_adj,'r-')
    legend('original signal','rescaled signal')
    plot(1:slen,repmat(mean(s(:,ii)),1,slen),'k--')
    plot(1:slen,repmat(min(s(:,ii)),1,slen),'k--')
    plot(1:slen,repmat(max(s(:,ii)),1,slen),'k--')
   
    plot(1:slen,repmat(mean(s_adj(:,ii)),1,slen),'r--')
    plot(1:slen,repmat(min(s_adj(:,ii)),1,slen),'r--')
    plot(1:slen,repmat(max(s_adj(:,ii)),1,slen),'r--')
end


end

end


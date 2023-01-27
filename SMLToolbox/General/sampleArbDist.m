function [randSamples] = sampleArbDist(xvals,cumDist,nSamples)
% [randSamples] = sampleArbDist(xvals,cumDist,nSamples)
%
% This is a quick and dirty script to sample from an arbitrary probability
% distribution. It will pick the mean value between the two closest data
% points from the cumulative probability distribution so ensure a high
% resolution of your distribution!
%
% INPUTS:
% xvals: the x-axis values
% cumDist: the cumulative probability distribution of your choice (defined [0,1])
% nSamples: number of samples you wish to draw
%
% OUTPUTS:
% randSamples: your random samples
%
% Created by SML Oct 2019

randSamples = NaN([1,nSamples]); % pre-allocate vector
yvals = rand([1,nSamples]); % draw random samples U([0,1]) of y-axis

for ii = 1:nSamples
    idx_low = cumDist <= yvals(ii); % which points on the cumulative distribution are lower?
    idx_high = cumDist >= yvals(ii); % which points on the cumulative distribution are higher?
    xvals_low = xvals(idx_low); % read off x-axis values that are lower than the uniform random draw
    xvals_high = xvals(idx_high); % read off x-axis values that are higher than the uniform random draw
    if ~isempty(xvals_low) && ~ isempty(xvals_high) % most cases
        xvals_low = xvals_low(end); % select the closest lower x-axis value
        xvals_high = xvals_high(1); % select the closest higher x-axis value
        randSamples(ii) = mean([xvals_low, xvals_high]); % average them together
    else % draw lower (or higher) than first (or last) yval
        randSamples(ii) = xvals(1)/2; % halve the first entry to find the wrapped mid-pt 
    end   
end

end
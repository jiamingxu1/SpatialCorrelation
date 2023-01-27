function [sumShiftsReq,meanShiftsReq] = get_seqSimilarity(v,a,fps)

% Created by SML June 2016

% Checks:
assert(isvector(v),'a must be a vector!')
assert(isvector(a),'a must be a vector!')
if size(v,1) ~= 1;  v = v'; end
if size(a,1) ~= 1;  a = a'; end

% Where are the events?
idx_v = find(v==1);
idx_a = find(a==1);

% If number of events not same, delete extra... (for Raposo's seqs):
if length(idx_v) ~= length(idx_a)
    if length(idx_v) > length(idx_a)
       idx_v = idx_v(1:length(idx_a));
    else
        idx_a = idx_a(1:length(idx_v));
    end
end

% Calculate total shift required and mean shift required to align seqs & convert to time units:
sumShiftsReq = sum(abs(idx_v - idx_a)) / fps;
meanShiftsReq = mean(abs(idx_v - idx_a)) /fps;

end

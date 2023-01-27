function [X_rounded] = roundToVal(X,rval)
% [X_rounded] = roundToVal(X,rval) is a function that rounds X (a scalar,
% vector, maxtrix) to the nearest multiple of rval.
%
% Created by SML Nov 2016

X_rounded = round(X/rval)*rval;

% SO THERE SEEMS TO BE OVERFLOW/UNDERFLOW PROBLEMS WITH THIS SCRIPT...

end
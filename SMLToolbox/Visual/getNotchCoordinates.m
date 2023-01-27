function [notchCoord] = getNotchCoordinates(theta,screenCenter,annulusRadius,notchLength)
% [notchStart, notchEnd] = getNotchCoordinates(theta,screenCenter,annulusRadius,notchLength)
%
% This function finds the pixel coordinates of a notch on an annulus
% centered on the screen. The notch is defined by two properties: its angle
% (theta, in deg) and the length (in pixels). 
%
% INPUTS:
% theta:- angle of the notch in degress (E=0, N=90, W=180, S=270)
% screenCenter:- a vector of the [x,y] screen center coordinates
% annulusRadius:- the radius of the annulus in pixels
% notchLength:- the length of the notch in pixels
% 
% OUTPUTS:
% notchCoord:- the [x,y] coordinates of the start of the notch (1st column) 
%              and the end of the notch (2nd column) in pixels
%
% Created by SML Sept 2019

% Beginning of the notch segment (at the annulus):
notchCoord(1,1) = screenCenter(1) + annulusRadius * cosd(theta); % x position
notchCoord(2,1) = screenCenter(2) - annulusRadius * sind(theta); % y position

% End of the notch segment (determined by notch length):
notchCoord(1,2) = screenCenter(1) + (annulusRadius + notchLength) * cosd(theta); % x position
notchCoord(2,2) = screenCenter(2) - (annulusRadius + notchLength) * sind(theta); % y position

end
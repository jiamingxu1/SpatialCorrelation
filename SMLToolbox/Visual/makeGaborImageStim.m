function [] = makeGaborImageStim(gaborSpecs,imName,imSize)
% This function will create Gabor image stimuli.
% 
% INPUTS:
% gaborSpecs:- (structure)
%       sigma:- sd of Gaussian filter in pix
%       theta:- orientation in degrees
%       lambda:- spatial frequencies pix/cycle
%       phase: phase in degrees
%       p2p_con:- max peak to peak contrast (0 to 1)
%       bgLum:- background luminance value
% imName:- data path and file name with extension (e.g., 'stimuli/stim1.png')
% imSize:- [width, height] of image in pix, best if odd numbers for centering purposes (default: 8 SD of gaussian mask)
%
% Created by SML Jan 2021

% Defaults:
if nargin < 3 
    imSize = []; % leave blank for now
    if nargin < 2
        imName = 'gaborStim.png'; 
        if nargin < 1
            gaborSpecs.sigma = 100; 
            gaborSpecs.theta = 0;
            gaborSpecs.lambda = 80;
            gaborSpecs.phase = 0;
            gaborSpecs.p2p_con = 1; 
            gaborSpecs.bgLum = 0.5;
        end
    end
end
if isempty(imSize)
    imSize = 2 * floor((8 * gaborSpecs.sigma)/2) + 1; % default (8 SD)
    imSize = [imSize, imSize]; % square
end

% Convert orientation, phase to radians:
theta = deg2rad(gaborSpecs.theta);
phase = deg2rad(gaborSpecs.phase);

% Create Guassian filter:
x_range = -imSize(1)/2+1:imSize(1)/2;
y_range = -imSize(2)/2+1:imSize(2)/2;
[x, y] = meshgrid(x_range, y_range);
gauss = exp( -(x.^2/(2*gaborSpecs.sigma^2)) -(y.^2/(2*gaborSpecs.sigma^2)) ) - 0.0001;
gauss(gauss<0) = 0;

% Generate grating:
grating =  cos((x.*cos(theta)+y.*sin(theta))*2*pi/gaborSpecs.lambda + phase); % basic sine wave
grating = 0.5 * grating; % shrink to range size (-1:1 -> -0.5:0.5 to match final 0:1)
grating = gaborSpecs.p2p_con * grating; % apply peak-to-peak scaling

% Make Gabor:
gabor = gauss .* grating; % apply Gaussian filter
gabor = gabor  + gaborSpecs.bgLum; % center on background luminance

% Save as image:
imwrite(gabor,imName,'BitDepth',8);

end
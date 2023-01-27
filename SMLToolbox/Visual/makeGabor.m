function [gabor] = makeGabor(sigma, theta, lambda, phase, lum, p2p_con)
% [gabor] = makeGabor(theta, lambda, lum, p2p_con, sigma, phase) is a
% function to create a gabor texture. 
%
% INPUTS:
% sigma:- sd of Gaussian filter in pix
% theta:- orientation in degrees... 
%         (N=0, E=90, S=180, W=270; negative values ok too)
% lambda:- spatial frequencies pix/cycle
% phase: phase in degrees
% p2p_con:- max peak to peak contrast (0 to 1)
% lum:- background luminance value

% Calculate texture size based on sigma (3 sd):
stimSize = 2 * floor((6 * sigma)/2) + 1;

% Convert orientation, phase to radians:
theta = deg2rad(theta);
phase = deg2rad(phase);

% Create Guassian filter:
[ x, y ] = meshgrid(-stimSize/2+1:stimSize/2);
gauss = exp( -(x.^2/(2*sigma^2)) -(y.^2/(2*sigma^2)) ) - 0.0001;
gauss(gauss<0) = 0;

% Generate grating and apply filter:
grating =  cos((x.*cos(theta)+y.*sin(theta))*2*pi/lambda + phase);
gabor = gauss.*grating *lum*p2p_con+lum;

% % Visualise:
% colormap gray(256);
% imagesc(gabor);
% % hide the axis
% axis off; axis image;
% % display without background
% set(gcf, 'menu', 'none', 'Color',[.5 .5 .5]);

end
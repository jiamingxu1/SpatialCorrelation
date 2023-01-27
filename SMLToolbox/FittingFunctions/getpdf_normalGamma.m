function [Y] = getpdf_normalGamma(x,tau,mu,kappa,alpha,beta)
% I couldn't find a standard Matlab function for the normal-Gamma.
% Additionally, as pointed out in Murphy 2007, Matlab uses the scale
% parameterisation of the Gamma, whereas most texts using the rate
% parameterisation. To avoid confusion, I have created this function to
% make sure I don't get confused or forget to re-parameterise. 
%
% Created by SML June 2020

Y = normpdf(x,mu,1./(kappa*tau)) .* gampdf(tau,alpha,1/beta);

end
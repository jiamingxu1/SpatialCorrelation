function [pm_errorBar] = getBinomialErrorBar(p,N,alpha)
% 
%
% Created by SML Oct 2017. 
% Updated by SML April 2018, allow vector inputs.

% Defaults:
if nargin < 3
    alpha = 0.05; % 95% CI
end

z = norminv(1 - alpha/2);
pm_errorBar = z * sqrt((p.*(1-p))./N);

end
function [par] = get_UMLpar2(xscale)

par.model = 'gaussian';    
par.ndown = 2;  % the parameter for the up-down sweetpoint selection rule
par.method = 'mean';    % the method for estimating the parameters from the
                        % the posterior parameter distribution. choose
                        % between 'mean' and 'mode'.
par.x0 = [5 11];
sel = randi(2);
par.x0 = par.x0(sel) * xscale;    % the initial signal strength
par.x_lim = [3 13] * xscale;   % the limits to the signal strength

par.alpha = struct(...
    'limits',[5 11] * xscale,...       %range of the parameter space for alpha
    'N',100,...                %number of alpha values. If this value is set to 1, then the first element of alpha.limits would be the assumed alpha and the alpha parameter is not estimated.
    'scale','lin',...         %the linear or log spacing. Choose between 'lin' and 'log'.
    'dist','flat',...         %prior distribution of the alpha parameter. Choose between 'norm' and 'flat'.
    'mu',0,...                %mean of the prior distribution.
    'std',0 ...              %standard deviation of the prior distribution.  
    );

par.beta = struct(...
    'limits',[0.2 5] * xscale,...      %range of the parameter space for beta
    'N',100,...                %number of beta values. If this value is set to 1, then the mean of beta_limits would be the assumed beta and the beta parameter is not estimated.
    'scale','log',...         %the linear or log spacing. Choose between 'lin' and 'log'.
    'dist','flat',...         %prior distribution of the beta parameter. Choose between 'norm' and 'flat'.
    'mu',0,...                %mean of the prior distribution.
    'std',1 ...               %standard deviation of the prior distribution.  
    );

par.gamma = 0;

par.lambda = struct(...
    'limits',[0 0.15],...      %range of the parameter space for lambda
    'N',61,...                 %number of lambda values. If this value is set to 1, then the first element of lambda.limits would be the assumed lambda and the lambda parameter is not estimated.
    'scale','lin',...         %the linear or log spacing. Choose between 'lin' and 'log'.
    'dist','flat',...         %prior distribution of the lambda parameter. Choose between 'norm' and 'flat'.
    'mu',0,...                %mean of the prior distribution.
    'std',0 ...             %standard deviation of the prior distribution.  
    );

% Settings used to run the experiment:
% par.lambda = struct(...
%     'limits',[0 0.1],...      %range of the parameter space for lambda
%     'N',10,...                 %number of lambda values. If this value is set to 1, then the first element of lambda.limits would be the assumed lambda and the lambda parameter is not estimated.
%     'scale','lin',...         %the linear or log spacing. Choose between 'lin' and 'log'.
%     'dist','flat',...         %prior distribution of the lambda parameter. Choose between 'norm' and 'flat'.
%     'mu',0,...                %mean of the prior distribution.
%     'std',0 ...             %standard deviation of the prior distribution.  
%     );

end
clc; clear; close all

par.model = 'gaussian';    
par.ndown = 2;  % the parameter for the up-down sweetpoint selection rule
par.method = 'mean';    % the method for estimating the parameters from the
                        % the posterior parameter distribution. choose
                        % between 'mean' and 'mode'.
par.x0 = 100;    % the initial signal strength
par.x_lim = [50 150];   % the limits to the signal strength

par.alpha = struct(...
    'limits',[50 150],...       %range of the parameter space for alpha
    'N',100,...                %number of alpha values. If this value is set to 1, then the first element of alpha.limits would be the assumed alpha and the alpha parameter is not estimated.
    'scale','lin',...         %the linear or log spacing. Choose between 'lin' and 'log'.
    'dist','flat',...         %prior distribution of the alpha parameter. Choose between 'norm' and 'flat'.
    'mu',0,...                %mean of the prior distribution.
    'std',0 ...              %standard deviation of the prior distribution.  
    );

% par.beta = struct(...
%     'limits',[0.4 0.6],...      %range of the parameter space for beta
%     'N',100,...                %number of beta values. If this value is set to 1, then the first element of beta.limits would be the assumed beta and the beta parameter is not estimated.
%     'scale','lin',...         %the linear or log spacing. Choose between 'lin' and 'log'.
%     'dist','flat',...         %prior distribution of the beta parameter. Choose between 'norm' and 'flat'.
%     'mu',0,...                %mean of the prior distribution.
%     'std',0 ...               %standard deviation of the prior distribution.
%     );

% par.beta = struct(...
%     'limits',[0.4 1],...      %range of the parameter space for beta
%     'N',100,...                %number of beta values. If this value is set to 1, then the first element of beta.limits would be the assumed beta and the beta parameter is not estimated.
%     'scale','log',...         %the linear or log spacing. Choose between 'lin' and 'log'.
%     'dist','norm',...         %prior distribution of the beta parameter. Choose between 'norm' and 'flat'.
%     'mu',0.5,...                %mean of the prior distribution.
%     'std',2 ...               %standard deviation of the prior distribution.
%     );

par.beta = struct(...
    'limits',[5 25],...      %range of the parameter space for beta
    'N',50,...                %number of beta values. If this value is set to 1, then the mean of beta_limits would be the assumed beta and the beta parameter is not estimated.
    'scale','lin',...         %the linear or log spacing. Choose between 'lin' and 'log'.
    'dist','flat',...         %prior distribution of the beta parameter. Choose between 'norm' and 'flat'.
    'mu',0,...                %mean of the prior distribution.
    'std',1 ...               %standard deviation of the prior distribution.  
    );

par.gamma = 0;

par.lambda = struct(...
    'limits',[0 0.15],...      %range of the parameter space for lambda
    'N',10,...                 %number of lambda values. If this value is set to 1, then the first element of lambda.limits would be the assumed lambda and the lambda parameter is not estimated.
    'scale','lin',...         %the linear or log spacing. Choose between 'lin' and 'log'.
    'dist','flat',...         %prior distribution of the lambda parameter. Choose between 'norm' and 'flat'.
    'mu',0,...                %mean of the prior distribution.
    'std',0 ...             %standard deviation of the prior distribution.  
    );

umlCATS = UML(par);
umlCATS.setPhi0([100,8,0,0]);
figure;
N = 1;
all_phi = zeros(N,4);

for jj = 1:N

    disp(jj)
    
% Trial loop:
for ii = 1:200

%     p = gamma+(1-gamma-true_lambda).*normcdf(uml.xnext,true_alpha,true_beta);
%     r = rand;
%     if r <= p 
%         r = 1;
%     else 
%         r = 0;
%     end 

    r = umlCATS.simulateResponse(umlCATS.xnext);
    umlCATS.update(r);   
    umlCATS.plotP();
%     
%     subplot(1,2,1); hold on
%     plot(true_beta,true_alpha,'wo','MarkerFaceColor','w'); hold off
%     subplot(1,2,2); hold on
%     plot(true_beta,true_lambda,'wo','MarkerFaceColor','w'); hold off
%     WaitSecs(0.1);

%     stimVals(ii) = uml.xnext;
%     respVals(ii) = r;

end

% conf = uml.getConf([0.025 0.975]);
all_phi(jj,:) = uml.phi(end,:);
% uml.getConf([0.025 0.975])

end

% figure;
% plot(stimVals,'o-')

% subplot(1,3,1)
% hist(all_phi(:,1),10);
% subplot(1,3,2)
% hist(all_phi(:,2),10);
% subplot(1,3,3)
% hist(all_phi(:,3),10);

% stimVals = round(2*stimVals)/2;
% [X,P,N,C] = get_PCorr(stimVals,respVals);
% [params,CIs] = CIs_cumulativeNormal(1000,X,N,C,[3 0.5 0],[0 0 1]);
% 
% figure; hold on
% plot(X,P,'ro')
% X = 0:0.01:5;
% p = gamma+(1-gamma-true_lambda).*normcdf(X,true_alpha,true_beta);
% plot(X,p,'k-')
% p = gamma+(1-gamma-params.lambda).*normcdf(X,params.mu,params.sigma);
% plot(X,p,'r-')
% 
% disp(params)
% disp(CIs)
clc; clear; close all

par = get_UMLpar;
uml = UML(par);
uml.setPhi0([100,8,0,0]);
figure;
N = 1;
all_phi = zeros(N,4);

for jj = 1:N

    disp(jj)
    
% Trial loop:
for ii = 1:200

    r = uml.simulateResponse(uml.xnext);
    uml.update(r);   
    uml.plotP();
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
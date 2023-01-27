% This script 

%% GLMM results with all factors:

% Set up 
ps_vals = 0:0.1:1;
n_ps = length(ps_vals);
mo = 0.06:0.001:0.14;

% % Prep figure:
% figure; hold on
% col = gradCustColBar(n_ps, ps_vals, [0 0 1], [1 0 0]);
% xlabel('Maximum click-flash Offset (sec)')
% ylabel('Probability of Response = Common Source')
% title('Response (coloured by % synch)')
% 
% % Plot each curve:
% for ii = 1:n_ps
%     ps = ps_vals(ii);
%     y = 1.5503 + -16.3261*mo + 0.9048*ps + 0.7560*mo*ps;
%     p = 1./(1+exp(-y));
%     plot(mo,p,'Color',col(ii,:))
% end

%%  Plot of only significant results alongside raw data:

% Prepare raw data:
load('data_maxOffsetRawData');
sIDs = unique(sID);
n_sIDs = length(sIDs);
mo2 = unique(maxOffset);
p_raw = NaN(length(mo2),n_sIDs);
n_raw = p_raw;
for ii = 1:n_sIDs
    [X,P,N,C] = get_PCorr(maxOffset(sID==sIDs(ii)),response(sID==sIDs(ii)));
    p_raw(:,ii) = P;
    n_raw(:,ii) = N;
end

% Make figure:
figure; hold on
xlabel('Maximum click-flash Offset (sec)')
ylabel('Probability of Response = Common Source')
y = 1.76 - 17*mo;
p = 1./(1+exp(-y));
plot(mo2,p_raw,'k-')
plot(mo,p,'r-')

% Export data to text file:
T = table(mo2*1000,p_raw(:,1),p_raw(:,2),p_raw(:,3),p_raw(:,4),p_raw(:,5),p_raw(:,6),p_raw(:,7),p_raw(:,8),p_raw(:,9),p_raw(:,10));
writetable(T,'figGLMM_rawSsData.txt','Delimiter',' ')
T = table(mo'*1000,p');
writetable(T,'figGLMM_fitData.txt','Delimiter',' ')

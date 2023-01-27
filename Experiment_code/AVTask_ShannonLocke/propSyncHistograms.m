% % Histogram of proportion synchronous:
% 
% rate = [4 6 8 10 12 14];
% nRate = length(rate);
% N = 1000;
% 
% ps = NaN(N,nRate);
% cc = NaN(119,nRate,N);
% for ii=1:nRate
%     for jj = 1:N
%         [~,seq1] = oneStreamAV_PoissonProcess(rate(ii),2,1/20,1,2,0);
%         [~,seq2] = oneStreamAV_PoissonProcess(rate(ii),2,1/20,1,2,0);
%         [~,~,ps(jj,ii)] = get_maxOffset(seq1,seq2,60);
%         [cc(:,ii,jj),lag] = slidingCrossCorrelationCoefficient(seq2,seq1,60);
%     end
% end
% 
% psRaposo = NaN(size(ps));
% ccRaposo = NaN(119,nRate,N);
% completeYN = 0;
% while completeYN == 0
%     filled = ~isnan(psRaposo(:,3:6));
%     if all(filled) == 1; completeYN = 1; continue; end
%     [rateRaposo, ~, propSyncRaposo, eV, eA] = getRaposoSeqs2(1);
%     idx_rate = find(rate == rateRaposo);
%     if isempty(idx_rate); continue; end
%     idx_ps = find(isnan(psRaposo(:,idx_rate)));
%     if isempty(idx_ps); continue; end
%     psRaposo(idx_ps(1),idx_rate) = propSyncRaposo;
%     [ccRaposo(:,idx_rate,idx_ps(1)),lag] = slidingCrossCorrelationCoefficient(eV,eA,40);
%     disp(sum(filled(:)))
% end
% 
% save('MyExpVsRaposo2', 'ps', 'psRaposo', 'cc', 'ccRaposo')

% load('HistogramDataMyExpVsRaposo')

load('MyExpVsRaposo')

stepVal = 0.1;
psVals = 0:stepVal:0.7;
nVals = length(psVals);
r_ps = round(ps/stepVal)*stepVal;
r_psR = round(psRaposo/stepVal)*stepVal;

p_ps = NaN(nVals,size(ps,2));
p_psR = NaN(nVals,1);
for ii = 1:nVals
    match_ps = r_ps == psVals(ii);
    match_psR = r_psR == psVals(ii);
    p_ps(ii,:) = sum(match_ps);
    p_psR(ii) = sum(match_psR(:));
end
p_ps = p_ps./repmat(sum(p_ps),[size(p_ps,1),1]);
p_psR = p_psR./repmat(sum(p_psR),[size(p_psR,1),1]);

figure
subplot(1,2,1); plot(psVals,p_ps)
subplot(1,2,2); plot(psVals,p_psR)

spsothingKernal = gausswin(9); % 80 ms
spsothingKernal = spsothingKernal / sum(spsothingKernal);
for ii = 1:nRate
    p_ps(:,ii) = conv(p_ps(:,ii), spsothingKernal, 'same'); 
end

% normalise the proportions:
p_ps = p_ps * (1/max(p_ps(:)));

figure
subplot(1,2,1); plot(psVals,p_ps)
subplot(1,2,2); plot(psVals,p_psR)

x = psVals';
y4 = p_ps(:,1);
y6 = p_ps(:,2);
y8 = p_ps(:,3);
y10 = p_ps(:,4);
y12 = p_ps(:,5);
y14 = p_ps(:,6);
T = table(x,y4,y6,y8,y10,y12,y14);
dataPath = '/Users/shannonlocke/GoogleDrive/Library/PosterRepository/posterCRCNS2016/figures/';
descriptors = {'histPropSync'};
extension = '.txt';
saveFile = createSaveFileName(descriptors,dataPath,extension);
writetable(T,saveFile,'Delimiter',' ')
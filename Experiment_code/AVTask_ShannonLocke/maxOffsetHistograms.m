% Histogram of maximum offset:

rate = [4 6 8 10 12 14];
nRate = length(rate);
N = 1000;

% mo = NaN(N,nRate);
% ps = mo;
% % cc = NaN(119,nRate,N);
% % for ii=1:nRate
% %     for jj = 1:N
% %         [~,seq1] = oneStreamAV_PoissonProcess(rate(ii),2,1/20,1,2,0);
% %         [~,seq2] = oneStreamAV_PoissonProcess(rate(ii),2,1/20,1,2,0);
% %         [mo(jj,ii),~,ps(jj,ii)] = get_maxOffset(seq1,seq2,60);
% %         [cc(:,ii,jj),lag] = slidingCrossCorrelationCoefficient(seq2,seq1,60);
% %     end
% % end
% 
% moRaposo = NaN(size(mo));
% psRaposo = moRaposo;
% ccRaposo = NaN(119,nRate,N);
% completeYN = 0;
% while completeYN == 0
%     filled = ~isnan(moRaposo(:,3:6));
%     if all(filled) == 1; completeYN = 1; continue; end
%     [rateRaposo, maxOffsetRaposo, propSyncRaposo, eV, eA] = getRaposoSeqs2(1);
%     idx_rate = find(rate == rateRaposo);
%     if isempty(idx_rate); continue; end
%     idx_mo = find(isnan(moRaposo(:,idx_rate)));
%     if isempty(idx_mo); continue; end
%     moRaposo(idx_mo(1),idx_rate) = maxOffsetRaposo;
%     psRaposo(idx_mo(1),idx_rate) = propSyncRaposo;
%     [ccRaposo(:,idx_rate,idx_mo(1)),lag] = slidingCrossCorrelationCoefficient(eV,eA,40);
%     disp(400-sum(filled(:)))
% end
% 
% save('MyExpVsRaposo','mo','moRaposo','ps', 'psRaposo', 'cc', 'ccRaposo')

load('HistogramDataMyExpVsRaposo')

stepVal = 0.01;
moVals = 0:stepVal:0.7;
nVals = length(moVals);
r_mo = round(mo/stepVal)*stepVal;
r_moR = round(moRaposo/stepVal)*stepVal;

p_mo = NaN(nVals,size(mo,2));
p_moR = NaN(nVals,1);
for ii = 1:nVals
    match_mo = r_mo == moVals(ii);
    match_moR = r_moR == moVals(ii);
    p_mo(ii,:) = sum(match_mo);
    p_moR(ii) = sum(match_moR(:));
end
p_mo = p_mo./repmat(sum(p_mo),[size(p_mo,1),1]);
p_moR = p_moR./repmat(sum(p_moR),[size(p_moR,1),1]);

figure
subplot(1,2,1); plot(moVals,p_mo)
subplot(1,2,2); plot(moVals,p_moR)

smoothingKernal = gausswin(9); % 80 ms
smoothingKernal = smoothingKernal / sum(smoothingKernal);
for ii = 1:nRate
    p_mo(:,ii) = conv(p_mo(:,ii), smoothingKernal, 'same'); 
end
p_moR = conv(p_moR, smoothingKernal, 'same');

% normalise the proportions:
p_mo = p_mo * (1/max(p_mo(:)));

figure
subplot(1,2,1); plot(moVals,p_mo)
subplot(1,2,2); plot(moVals,p_moR)

x = moVals'*1000;
yR = p_moR;
y4 = p_mo(:,1);
y6 = p_mo(:,2);
y8 = p_mo(:,3);
y10 = p_mo(:,4);
y12 = p_mo(:,5);
y14 = p_mo(:,6);
T = table(x,yR,y4,y6,y8,y10,y12,y14);
dataPath = '/Users/shannonlocke/GoogleDrive/Library/PosterRepository/posterCRCNS2016/figures/';
descriptors = {'histMaxOffset'};
extension = '.txt';
saveFile = createSaveFileName(descriptors,dataPath,extension);
writetable(T,saveFile,'Delimiter',' ')
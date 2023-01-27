% Load data:
dataPath = [cd '/data_modelComparison' '/'];
optSigma = table2array(readtable([dataPath, 'optSigma'],'Delimiter',' '));
bestSigma = table2array(readtable([dataPath, 'bestSigma'],'Delimiter',' '));
stimLevel = table2array(readtable([dataPath, 'stimLevel'],'Delimiter',' '));
resp = table2array(readtable([dataPath, 'resp'],'Delimiter',' '));
optMu = table2array(readtable([dataPath, 'optMu'],'Delimiter',' '));
bestMu = table2array(readtable([dataPath, 'bestMu'],'Delimiter',' '));
nSs = 10;

% Get model evidence (llh) and do model comparison with SPM toolbox:
n = ones(200,1);
for sess = 1:4 % EACH SESSION
    llh_o = zeros(nSs,1);
    llh_b = llh_o;
    
    for s = 1:nSs % EACH SUBJECT
         idx = (sess-1)*10 + s;
         SL = stimLevel(:,idx);
         r = resp(:,idx);
         n_mu = 100;
         mu = linspace(-4,4,n_mu);
         delta_mu = mu(2) - mu(1);
         
         useOldMethodYN = 0;
         if useOldMethodYN == 1
             % nllh_o = ll_Cum([optMu(s,sess) optSigma(s,sess)], SL, n, r, 0);
             nllh_o = ll_Cum([0 optSigma(s,sess)], SL, n, r, 0);
             llh_o(s) = -nllh_o;
             % nllh_b = ll_Cum([optMu(s,sess) bestSigma(s,sess)], SL, n, r, 0);
             nllh_b = ll_Cum([bestMu(s,sess) bestSigma(s,sess)], SL, n, r, 0);
             % nllh_b = ll_Cum([0 bestSigma(s,sess)], SL, n, r, 0);
             llh_b(s) = -nllh_b;
         else
             for ii = 1:n_mu
                 nllh_o = ll_Cum([mu(ii) optSigma(s,sess)], SL, n, r, 0);
                 llh_o(s) = llh_o(s) - nllh_o * delta_mu;
                 nllh_b = ll_Cum([mu(ii) bestSigma(s,sess)], SL, n, r, 0);
                 llh_b(s) = llh_b(s) - nllh_b * delta_mu;
             end
         end
         
    end
    
    disp('Log posterior odds (opt/best) for each subject:')
    disp(llh_o-llh_b)
    [alpha,exp_r,xp,pxp,bor] = spm_BMS ([llh_o llh_b]); % M1 = opt, M2 = best
    disp('Exceedance probabilities of each model (opt, best)')
    disp(xp)
end
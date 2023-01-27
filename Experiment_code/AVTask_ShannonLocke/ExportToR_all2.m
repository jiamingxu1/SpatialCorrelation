function [] = ExportToR_all2()

all_init = {'EN','GK','HL','RD','SL','JZ','MS','PS','MR','EG','DB'};
sIDs = [124 139 876 369 773 308 552 595 940 929 429];
set(0,'DefaultFigureWindowStyle','docked')

% Empty vectors:
sID = [];
session = [];
modality = [];
aRateC = [];
aRateS = [];
vRateC = [];
vRateS = [];
dur = [];
response = [];
muEst = [];
sigmaEst = [];
lambdaEst = [];

for ii = 1:length(all_init) % EACH SUBJECT
    for jj = 1:4 % EACH SESSION
        
        % Find and load file:
        fileNameString = [all_init{ii} '_AVTemporalTask_rateJND_V5_final_S' num2str(jj)];
        dataPath = ['data_AVTemporalTask_rateJND_V5/' all_init{ii} '/'];
        allMatchedFiles = dir([dataPath fileNameString '*']);
        try
            allMatchedFiles = allMatchedFiles.name;
            load([dataPath allMatchedFiles]);
            
            % -- START: GET LAMBDA FROM UML -- %
            
            lambda = NaN(1,3);
            sigma = NaN(1,3);
            mu = NaN(1,3);
            
            for mm = 1:3 % Each modality
                
                % Choose the UML objects for modality
                switch mm
                    case 1
                        sel_uml = visUML;
                    case 2
                        sel_uml = audUML;
                    case 3
                        sel_uml = multUML;
                end
                
                % Create UML object to iterate through the posterior updates:
                par = get_UMLpar2(1);
                uml_corr = UML(par);
                
                % Iterate through all trials:
                for nn = 1:200 % Each trial
                    r = sel_uml.r(nn); % Get response
                    uml_corr.xnext = sel_uml.x(nn); % Change xnext value to that shown to PS
                    uml_corr.update(r);
                end
                
                % View likelihood function:
                figure; uml_corr.plotP();
                title([all_init{ii} ' in ' num2str(jj) ' mod ' num2str(mm)])
                figname = ['lambdaFits/nll_' all_init{ii} 'in' num2str(jj) 'mod' num2str(mm)];
                savefig(figname)
                close all
                
                % Get lambda value:
                val_lambda = linspace(0,0.15,61); % linspace(0,0.1,41);
                nll_lambda = getLambda(uml_corr.p);
                lambda(mm) = val_lambda(nll_lambda == max(nll_lambda));
                sigma(mm) = uml_corr.phi(end, 2);
                mu(mm) = uml_corr.phi(end, 1);
                
                % Visually inspect lambda values for pinning:
                figure;
                plot(val_lambda, nll_lambda, 'ro-')
                ylabel('prop to likelihood')
                xlabel('lambda')
                title([all_init{ii} ' in ' num2str(jj) ' mod ' num2str(mm)])
                figname = ['lambdaFits/lambda_' all_init{ii} 'in' num2str(jj) 'mod' num2str(mm)];
                savefig(figname)
                
            end
            disp([ii jj mm])
            disp(lambda)
                        
            % -- END: GET LAMBDA FROM UML -- %
            
            
            % Get the rates and durations for comparison and standard stimuli:
            % -------------------------------------------------- %
            % fx: rate = sum(X) / [(1/60)*length(X)] = fps*sum(x)/length(X)
            
            fps = exp.hardware.fps;
            all_dur = exp.designMat(:,3);
            mod_idx = exp.designMat(:,2); % Which modality for comparisons
            rateA = NaN(600,1); % Comparison stimuli, auditory stimulus
            rateV = NaN(600,1); % Comparison stimuli, visual stimulus
            rateAs = NaN(120,1); % Comparison stimuli, auditory stimulus
            rateVs = NaN(120,1); % Comparison stimuli, visual stimulus
            
            for kk = 1:600 % Get comparison rates
                selA = cell2mat(all_ear(kk));
                selV = cell2mat(all_frameType(kk))-1;
                rateA(kk) = (fps*sum(selA))/length(selA);
                rateV(kk) = (fps*sum(selV))/length(selV);
            end
            for kk = 1:120 % Get standard rates
                try
                    selA = cell2mat(all_ear_standard(kk));
                    selV = cell2mat(all_frameType_standard(kk))-1;
                    rateAs(kk) = (fps*sum(selA))/length(selA);
                    rateVs(kk) = (fps*sum(selV))/length(selV);
                end
            end
            % Reshape standard rates:
            rateAs = repmat(rateAs',5,1);
            rateAs = rateAs(:);
            rateVs = repmat(rateVs',5,1);
            rateVs = rateVs(:);
            
            % Store results:
            % -------------- %
            
            sID = [sID; repmat(sIDs(ii),600,1)];
            session = [session; repmat(jj,600,1)];
            
            % Visual only trials:
            modality = [modality; repmat(1,200,1)];
            vRateC = [vRateC; rateV(mod_idx==1)];
            aRateC = [aRateC; NaN(200,1)];
            vRateS = [vRateS; rateVs(mod_idx==1)];
            aRateS = [aRateS; rateAs(mod_idx==1)];
            dur = [dur; all_dur(mod_idx==1)];
            response = [response; visUML.r];
            muEst = [muEst; repmat(mu(1),200,1)];
            sigmaEst = [sigmaEst; repmat(sigma(1),200,1)];
            lambdaEst = [lambdaEst; repmat(lambda(1),200,1)];
            
            % Auditory only trials:
            modality = [modality; repmat(2,200,1)];
            vRateC = [vRateC; NaN(200,1)];
            aRateC = [aRateC; rateA(mod_idx==2)];
            vRateS = [vRateS; rateVs(mod_idx==2)];
            aRateS = [aRateS; rateAs(mod_idx==2)];
            dur = [dur; all_dur(mod_idx==2)];
            response = [response; audUML.r];
            muEst = [muEst; repmat(mu(2),200,1)];
            sigmaEst = [sigmaEst; repmat(sigma(2),200,1)];
            lambdaEst = [lambdaEst; repmat(lambda(2),200,1)];
            
            % Multisensory trials:
            modality = [modality; repmat(3,200,1)];
            vRateC = [vRateC; rateV(mod_idx==3)];
            aRateC = [aRateC; rateA(mod_idx==3)];
            vRateS = [vRateS; rateVs(mod_idx==3)];
            aRateS = [aRateS; rateAs(mod_idx==3)];
            dur = [dur; all_dur(mod_idx==3)];
            response = [response; multUML.r];
            muEst = [muEst; repmat(mu(3),200,1)];
            sigmaEst = [sigmaEst; repmat(sigma(3),200,1)];
            lambdaEst = [lambdaEst; repmat(lambda(3),200,1)];
            
        catch
            fprintf('\n\n Selected file could not be loaded!\n\n');
            disp(allMatchedFiles)
        end
        
    end
end

T = table(sID,session,modality,vRateC,aRateC,vRateS,aRateS,dur,response,muEst,sigmaEst,lambdaEst);
filesave = '/Users/shannonlocke/GoogleDrive/Library/Experiments/AudiovisualRateDiscrimination/DataAnalysis/RateJNDinR/data_raw_rateJND/rateJNDdata.txt';
writetable(T,filesave,'Delimiter',' ')

end

function [Y] = getLambda(X)

Y = squeeze(sum(sum(exp(X))));

end
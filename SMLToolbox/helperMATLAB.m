 %% HELPER FILE FOR MATLAB %%

% SML is forgetful even in her youth. This file is a cheat sheet for her 
% and anyone she likes enough to share this with, to help them program in 
% Matlab. Many functions called here are from the SML toolbox, so if you
% can't understand what the hell is going on, that might be why. 

% Created waaaay too late (July 2017) by SML.

addpath(genpath('/Users/shannonlocke/Applications/Psychtoolbox'))
addpath(genpath('/Users/shannonlocke/Documents/Research/SMLToolbox'))
addpath(genpath('/Users/shannonlocke/Documents/MATLAB/tpfsutils')) % Load toolbox
addpath(genpath('/Users/shannonlocke/Documents/MATLAB/MATLABgit')) % Load toolbox

%% FAVOURITES %%

quickSetupPlot(h,ttl,xlab,ylab,xLU,yLU,leg,legPos)

%% QUICK SET UP -- PARIS LAB %%

addpath(genpath('/Users/shannonlocke/Google Drive/Library/SMLToolbox'))
set(0,'DefaultFigureWindowStyle','docked') % docked

%% QUICK SET UP -- NYU LAB %%

rmpath(genpath('/e/3.2/p3/locke/Documents/MATLAB/SMLToolbox'))
addpath(genpath('/Local/Users/locke/GoogleDrive/Library/SMLToolbox'))
set(0,'DefaultFigureWindowStyle','docked') % docked

%% FILES AND FOLDERS %% 

% Directory commands:
ls('/someFolder') % displays the content of the folder in command window

% Relative paths:
load('../../data/myData.mat') % each '../' moves up one level

% Write to txt file:
T = table(var1,var2,var3);
savefile = [cd '/someFolder/someFileName.txt'];
writetable(T,savefile,'Delimiter',' ')

% Read from txt file:
savefile = [cd '/someFolder/filename.txt'];
fitResults = readtable(savefile,'Delimiter',' ');

%% BASICS %%

% Conditionals and loops:
cats = 0;
if (1 == 1); elseif (1 == 2); else cats = 100; end
for ii = 1:10; end
switch cats; case 0; cats = 0; case 1; cats = 0; case 100; cats = 0; end
while cats > 0; cats = cats - 1; end

% Boolean:
TF = strcmp(S1,S2);

% Pre-allocating space:
X = zeros([n1,n2,n3]);
X = nan([n1,n2,n3]);

% Get user input:
sel = input('Message');

% Conditonal debugger:
keyboard

% Warnings and errors:
if checkVal == TRUE; error('This is my error message. Print this number %i',x); end
if checkVal == TRUE; warning('This is my warning message. Print this number %i',x); end


%% EXPERIMENT SETUP %%

% [SMLToolbox] Shuffle all/specific rows/columns:
[X] = ShuffleRC(X,dim,specrange);

%% DATA HANDLING %%

% Dimensions:
vectorYN = isvector(X); % test if X is a vector
rowYN = isrow(X); % test if X is a row vector
colYN = iscolumn(X); % test if X is column vector

% Sorting a vector:
[sortedVector,idx] = sort(unsortedVector,'ascending');

% Reshaping a matrix:
X_reshaped = reshape(X,[M,N,P]);
X_reshaped = reshape(X,M,N,[]);

% [SMLToolbox] Round to nearest multiple of chosen number:
[X_rounded] = roundToVal(X,rval);

% Create a rectangular grid of values:
[X1,X2] = meshgrid(x1vals,x2vals); % 2D or 3D
[X1,X2,X3] = ndgrid(x1vals,x2vals,x3vals); % 1-D to N-D

% Tables:
T = join(T_passive,T_active,'Keys',[1,2]); % match to active results

%% DATA FILTERING %%

% Moving average:
movmean(X,n,dim); % current sample, (n-1)/2 behind and (n-1)/2 forward
movmean(X,[nb nf],dim); % current sample, nb behind and nf forward

% Low-pass filter and down-sample:
Y = decimate(X,5);

%% DATA EXPLORATION %%

% [SMLToolbox] Compute frequency information for histogram:
[x,f,p] = freqTable(X,rval);

% [SMLToolbox] Prepare frequency data for binary variables:
[X,P,N,C] = get_PCorr(stimVals,respVals,rval);

% [SMLToolbox] Arrange data for n-back analysis:
nbackMat = get_nbackMat(X,n,concatYN);

% [SMLToolbox] Compute cross-correlations and autocorrelations:
[r,lag] = slidingCrossCorrelationCoefficient(X,Y,truncateBy);

% [SMLToolbox] Straightfoward way to calculate a FFT:
[f,amp,phase] = calcFFT(X,sf,plotYN); 

%% RANDOMISATION %% 

% Setting random seed(!):

%% STATISTICS AND MODELLING %%

% Fitting a straight line:
xvals = (1:100)';
yvals = 2*xvals + 15 + 3*rand(size(xvals));
beta = [ones(size(xvals)) xvals]\yvals;
linefit = beta(2) * xvals + beta(1);

%% STATISTICAL FUNCTIONS %%

invnorm = @(p, mu, sigma) mu + sqrt(2) * sigma .* erfinv(2 * p - 1); % quantile function (inverse CDF)
cumnorm = @(z, mu, sigma) .5 * (1 + erf((z - mu) ./ (sqrt(2)*sigma))); % CDF

%% PLOTTING %%

% [SML Toolbox] Quick-edit of plot:
quickSetupPlot(h,ttl,xlab,ylab,xLU,yLU,leg,legPos)

% Configure figure popup window behaviour:
set(0,'DefaultFigureWindowStyle','docked') % docked
set(0,'DefaultFigureWindowStyle','normal') % undocked

% Plot styles:
plot(xval,yval,'b-o')
errorbar(xval,yval,errval,'b-o') % line plot with symmetrical error bars
scatter(xval,yval,sizeMarker,colourVal,'filled') % scatter plot great for size, colour, fill properties
heatmap(X);

% Setting the figure properties:
FS = 14; LW = 2;
set(gca,'FontSize',FS)
set(gca,'LineWidth',LW)

% Axis properties:
xlim([0 100])
xticks([0 50 100])
xticklabels({'low', 'medium', 'high'})
xlabel('Variable')
   
% Legend properties:
legend boxoff

% Additional plot elements:
colormap('Pink'); % https://fr.mathworks.com/help/matlab/ref/colormap.html
caxis([0 5]); % range for colour map
colorbar

% Saving a plot as an eps file:
dataPath = [cd '/Figures/'];  
extension = '.eps';
descriptors = {'expName', 'analysisType', 'someSpec', num2str(sID)};
saveFile = createSaveFileName(descriptors,dataPath,extension);
hh = figure('position', [0, 0, 1000, 1000]);
plot(xvals,yvals);
set(hh, 'Visible', 'off');
set(hh, 'PaperPositionMode', 'auto');
saveas(hh,saveFile,'epsc');

% [SMLToolbox] Automatically setting subplot space:
[R,C] = getRowsCols(N,longDim);

%% PSYCHTOOLBOX %%

%% SOUNDS %%

% Basic load and play sound:
[y,Fs] = audioread('typewriter.mp3');
sound(y,Fs);

%% NON-MATLAB SCRIPTS %%

% Run R-script from within Matlab (same directory), status = 0 if sucessful:
status = system('R CMD BATCH scriptname.R');
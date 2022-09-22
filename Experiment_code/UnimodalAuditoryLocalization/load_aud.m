function [yMat, freqMat, nrchannels] = load_aud(ExpInfo)

% addpath('/Users/oliviaxujiaming/Desktop/GitHub/SpatialCorrelation/Experiment_code/UnimodalAuditoryLocalization/natsortfiles');
% fileList = natsortfiles(dir(ExpInfo.fileDir));
% fileList = (dir(ExpInfo.fileDir));

yMat = cell(ExpInfo.nAudFile,1);
freqMat = zeros(1,ExpInfo.nAudFile);

for iF = 1: 21 % iF=1
%fileName = fileList(iF).name; 
fileName = ExpInfo.fileName{iF};
%[tempY, freqMat(:,iF)] = audioread(fileName);
 [tempY,freqMat(iF)] = psychwavread(fileName); 
yMat{iF,1} = tempY';
end

nrchannels = 2;

end

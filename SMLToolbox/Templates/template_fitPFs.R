# ----------------------------------- #
# Template: Psychometric Function Fit #
# ----------------------------------- #
#
# Created by SML Jan 2017

# Packages:
library("dplyr")
library("rstan")
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Preamble:
datapath <- "/Users/shannonlocke/GoogleDrive/Library/Experiments/expName/dataAnalysis"
setwd(dataPath)

# Data handling functions:
getData <- function(expName,dataType) {
  dataPath <- paste("data_raw_", expName, "/", sep = "")
  fname <- paste(dataType,".txt", sep = "")
  fetchFile <- paste(dataPath, fname, sep = "")
  indata <- read.table(fetchFile, header = T)
}
exportAnalysedData <- function(data, expName, analysisName) {
  dataPath <- paste("data_analysed_", expName, "/", sep = "")
  fname <- paste(analysisName, ".txt", sep = "")
  newFile <- paste(dataPath, fname, sep = "")
  write.table(data, newFile, quote = FALSE, row.names = FALSE, sep=" ")
}

# Load data:
expName <- "expName"
indata <- getData(expName,"rawData")
params <- getData(expName,"modelParams")
indata <- indata[order(indata$PF),]

# Fit the PFs:
setwd("/Users/shannonlocke/GoogleDrive/Library/SMLToolbox/fitPFs")
source("toolbox_fitPFs.R")
sims <- run_fitPF_MuSigma_Independent(indata, mu_range, sigma_range, iter, chains)

# Store results:
PFs <- unique(indata[c("PF")])
PFs <- unique(indata[c("PF")])
PFs$muEst <- colMeans(sims$mu)
PFs$muLow95CI <- sims$mu %>%  apply(2, quantile, 0.025)
PFs$muHigh95CI <- sims$mu %>% apply(2, quantile, 0.975)
PFs$sigmaEst <- colMeans(sims$sigma)
PFs$sigmaLow95CI <- sims$sigma %>%  apply(2, quantile, 0.025)
PFs$sigmaHigh95CI <- sims$sigma %>% apply(2, quantile, 0.975)

# Save results
setwd(dataPath)
exportAnalysedData(PFs, expName, "fitPF_paramVals")
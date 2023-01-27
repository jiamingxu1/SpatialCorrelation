## HELPER FILE FOR R ##

# If you thought the Matlab helper file came too late, hold your hat.
# This helper file is arguably even more important, given that every
# time I open R my mind is a blank void. "How do I even?" A haunting
# voice in my head says ad nauseam. Despair no more, Shannon! 
#
# Created by SML Jan 2018 (new year, new me)

# ---------------------------------------------------------------- #
# PREAMBLE:

# Load common packages:
library("dplyr")
library("ggplot2") # for creating pretty graphs
library("rstan") # for fitting Bayesian models
library("shinystan") # for checking the fits of rstan
library("lme4") # for fitting Linear-Mixed-Effects models

# ---------------------------------------------------------------- #
# BASICS:

# See content/edit of workspace:
ls() # lists current variables
objects() # lists current variables
rm(x) # removes variable x

# Creating variables:
y <- factor(x) # a factor
z <- data.frame(x,y) # a dataframe

# ---------------------------------------------------------------- #
# DATA HANDLING:

# Load data from a text file:
dataPath <- "FolderA/FolderB/"
fileName <- "myFile.txt"
fetchFile <- paste(dataPath, fileName, sep="")

# Look at the data:
class(x) # Check variable type
head(x,n) # see first n entries of x, or leave n blank (default: n=10)
str(x) # compactly display 

# Combine data:
x <- c(1,2,3)
x <- c("cats","dogs","kangaroos")
z <- rbind(x,y)
Z <- cbind(x,y)

# ---------------------------------------------------------------- #
# DATAFRAMES:

# Combining dataframes by only considering columns that are in both dataframes:
common.names <- intersect(colnames(database.one), colnames(database.two))
combined.database <- rbind(database.one[, common.names], database.two[, common.names])

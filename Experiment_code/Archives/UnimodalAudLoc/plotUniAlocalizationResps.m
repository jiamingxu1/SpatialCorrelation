% This script plots histograms for the unimodal localization responses
clear all; close all; clc; rng(1);

%% load and organize data
C = load('UniAlocalization_sub99.mat');
actualLoc = C.UniAlocalization_data{1}.result(:,1);
response = C.UniAlocalization_data{1}.result(:,2);

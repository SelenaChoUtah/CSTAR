function [fuzzEn] = FuzEn(ts1)

% Uses crossfuzzyen.m to calculate the cross fuzzy entropy between two
% timeseries ts1 and ts2 using a lag equal to the first minimum of the 
% mutual information function within one timeseries. ts1 and ts2 need not 
% be the same length, but CFuzzyEn will shorten the longer of the two 
% timseries to make equal lengths.

% Written by Peter Fino

[n1,b1]=size(ts1);

x1=zscore(ts1);

r = 0.15; % tolerance parameter selection
ns = 2; % similarity function parameter selection
lags = 0:1:64;
[MI1,lags] = ami(x1,x1,lags);
[v1,tau1] = firstMinimum(MI1);
tau = round(mean(tau1));
M = 2;
fuzzEn=mvfuzzyen(M,r,tau,ns,x1');



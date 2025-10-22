function [CFEn] = CFuzzyEn(ts1,ts2)

% Uses crossfuzzyen.m to calculate the cross fuzzy entropy between two
% timeseries ts1 and ts2 using a lag equal to the first minimum of the 
% mutual information function within one timeseries. ts1 and ts2 need not 
% be the same length, but CFuzzyEn will shorten the longer of the two 
% timseries to make equal lengths.

% Written by Peter Fino

[n1,b1]=size(ts1);
[n2,b2]=size(ts2);
if b1 > n1 % transpose TS if input is a row vector
    ts1=ts1';
    ts2=ts2';
    [n1,b1]=size(ts1);
    [n2,b2]=size(ts2);
end
if n1>n2
    ts1=ts1(1:n2,:);
    [n1,b1]=size(ts1);
end
if n2>n1
    ts2 = ts2(1:n1,:);
    [n2,b2]=size(ts2);
end

for i=1:b1
    min1 = min(ts1(:,i)); M1= max(ts1(:,i));
    min2 = min(ts2(:,i)); M2= max(ts2(:,i));
    ts1(:,i)= (ts1(:,i)-min1)/(M1-min1);
    ts2(:,i)= (ts2(:,i)-min2)/(M2-min2);
end

x1=zscore(ts1);
x2=zscore(ts2);
r = 0.15; % tolerance parameter selection
ns = 2; % similarity function parameter selection
lags = 0:1:64;
[MI1,lags] = ami(x1,x1,lags);
[MI2,lags] = ami(x2,x2,lags);
[v1,tau1] = firstMinimum(MI1);
[v2,tau2] = firstMinimum(MI2);
tau = 1;%round(mean([tau1;tau2]));
M = 1;
CFEn=crossfuzzyen(M,r,tau,ns,x1',x2');

end



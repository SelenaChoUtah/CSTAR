function [SE] = CompMMSE_Fuzzy(TS,Scales)

% Uses mvfuzzyen.m, a modified version of mvsampen_full.m from the 
% "Matlab_Multivariate_Multiscale_Entropy Toolbox" provided by Ahmed and 
% Mandic, 2011, "Multivariate multiscale entropy: a tool for complexity 
% anaylsis of multichannel data" Physical Review E
%
% mvsampen_full was modified to calculate the fuzzy entropy by Peter Fino.
% Last Modified: 2/29/2016


%% set parameters (according to Ahmed and Mandic (2011))


x=TS;
[n,b]=size(x);
if b > n % transpose TS if input is a row vector
    x=TS';
    [n,b]=size(x);
end

for i=1:b
    m1 = min(x(:,i)); M1= max(x(:,i));
    x(:,i)= (x(:,i)-m1)/(M1-m1);
end

x=zscore(x);
SE = zeros(1,Scales);
wind_std = 240;
for i=1:n-wind_std
    sdw(i) = std(x(i:i+wind_std));
end
sd = median(sdw);
r = 0.2*sd; % tolerance parameter selection
ns = 2; % similarity function parameter selection
m = 2;
t = 1;
for i=Scales
    for j = 1:i
        for p=1:b
            y = CoarseGrain(x(j:end,p),i);
            X(:,p)=y;
        end
        M = m.*ones(1,b); % parameter selection
        tau = t.*ones(1,b); % parameter selection
        e=mvfuzzyen(M,r,tau,ns,X');
        % SE(i)=SE(i) + e/i;
        SE(j)=SE(j) + e/j;
        clear X;
    end
end




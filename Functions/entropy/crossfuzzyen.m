
function e=crossfuzzyen(M,r,tau,n,ts1,ts2)
% This function calculates cross fuzzy entropy according to Xie et al. 2010
% Information Sciences
% Inputs:

% M - embedding vector parameter
% r - threshold scalar parameter 
% tau - time lag vector parameter
% n - gradient of the exponential similarity function
% ts1 - first time series-a matrix of size nvarxnsamp
% ts2 - second time series of equal size

% Output:
% e- scalar quantity


%number of match templates of length m closed within the tolerance r where m=sum(M) is calculated first
mm=max(M);
mtau=max(tau);
nn=mm*mtau;


[nvar,nsamp]=size(ts1);
N=nsamp-nn;
A1=embd(M,tau,ts1);%all the embedded vectors are created
A2=embd(M,tau,ts2); %embedded vectors for ts2 created
A1bar = mean(A1,2); % create baselines
A2bar = mean(A2,2); % create baselines
Xi = A1 - repmat(A1bar,1,M);
Yi = A2 - repmat(A2bar,1,M); %subtract baselines
delta = pdist2(Xi,Yi,'chebychev');%infinite norm is calculated between all possible pairs

u1=exp(-(delta./r).^n);
p1=sum(sum(u1))/(N*N);%the sum of the similarity function
% clear  delta r1 c1 v1 A1 A2;

% repeat for m= m+1
M=repmat(M,nvar,1);
I=eye(nvar);
M=M+I;

B1=[];
B2 = [];
B1=embd(M,tau,ts1);%all the embedded vectors are created
B2=embd(M,tau,ts2); %embedded vectors for ts2 created
B1bar = mean(B1,2); % create baselines
B2bar = mean(B2,2); % create baselines
Xi2 = B1 - repmat(B1bar,1,M);
Yi2 = B2 - repmat(B2bar,1,M); %subtract baselines
delta2 = pdist2(Xi2,Yi2,'chebychev');%infinite norm is calculated between all possible pairs

u2=exp(-(delta2./r).^n);
p2=sum(sum(u2))/(N*N);
% clear  delta2 r2 c2 v2 B1 B2;


e=log(p1/p2);



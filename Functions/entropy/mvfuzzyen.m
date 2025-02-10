
function e=mvfuzzyen(M,r,tau,n,ts)
% This function calculates multivariate fuzzy sample entropy using the full multivariate approach
% Inputs:

% M - embedding vector parameter
% r - threshold scalar parameter 
% tau - time lag vector parameter
% n - gradient of the exponential similarity function
% ts - multivariate time series-a matrix of size nvarxnsamp

% Output:
% e- scalar quantity

% Edited to calculate fuzzy entropy by Peter Fino
% Last modified: 2/29/2016


%number of match templates of length m closed within the tolerance r where m=sum(M) is calculated first
mm=max(M);
mtau=max(tau);
nn=mm*mtau;


[nvar,nsamp]=size(ts);
N=nsamp-nn;
A=embd(M,tau,ts);%all the embedded vectors are created
y=pdist(A,'chebychev');%infinite norm is calculated between all possible pairs
u1=exp(-(y./r).^n); %Define the similarity function 2/29/2016
% [r1,c1,v1]= find(y<=r);% threshold is implemented
% p1=numel(v1)*2/(N*(N-1));%the probability that two templates of length m are closed within the tolerance r
p1=sum(u1)*2/(N*(N-1));%the sum of the similarity function 2/29/2016
% clear  y r1 c1 v1 A;

M=repmat(M,nvar,1);
I=eye(nvar);
M=M+I;

B=[];

% number of match templates of length m+1 closed within the tolerance r where m=sum(M) is calculated afterwards
for h=1:nvar
Btemp=embd(M(h,:),tau,ts);
B=vertcat(B,Btemp);% all the delay embedded vectors of all the subspaces of dimension m+1 is concatenated into a single matrix
Btemp=[];
end
z=pdist(B,'chebychev'); %now comparison is done between subspaces
u2=exp(-(z./r).^n);
% [r2,c2,v2]= find(z<=r);
% p2=numel(v2)*2/(nvar*N*(nvar*N-1));
p2=sum(u2)*2/(nvar*N*(nvar*N-1));
% clear  z r2 c2 v2 B;


e=log(p1/p2);



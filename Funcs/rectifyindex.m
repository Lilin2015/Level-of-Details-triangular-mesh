function [ recV,recF ] = rectifyindex( V,F )
%RECTIFYINDEX Summary of this function goes here
%   V is nV*3
%   F is nF*3

nV=size(V,1);
nF=size(F,1);

num_of_NaN=zeros(nV,1);
sum=0;
for i=1:nV
    if isnan(V(i,1))
        sum=sum+1;
    end
    num_of_NaN(i)=sum;
end

recF=zeros(nF,3);

for i=1:nF
    for j=1:3
        recF(i,j)=F(i,j)-num_of_NaN(F(i,j));
    end
end

recV=zeros(nV-sum,3);
j=1;
for i=1:nV
    if ~isnan(V(i,1))
        recV(j,:)=V(i,:);
        j=j+1;
    end
end

end
function cp=SMLL(matrix)
%% Function : caculate the Sum-modified-Laplacian measure of image
%=============================================================

% QU Xiao-BO, 
% Xiamen University in P.R.China, April 2009.

% ---------
% Author:  Qu Xiao-Bo    <qxb_xmu [at] yahoo.com.cn>    Aug.28,2008
%          Postal address:
% Rom 509, Scientific Research Building # 2,Haiyun Campus, Xiamen University,Xiamen,Fujian, P. R. China, 361005
% Website: http://quxiaobo.go.8866.org
%=============================================================
%%
window_wide=7;
spread=(window_wide-1)/2;
disp('SML is computing...')
matrix=double(matrix);
[row,column]=size(matrix);
cp=zeros(row,column);
temp=matrix.*0;
matrix_en=padarray(matrix,[spread spread],'symmetric');

for i=2:row+1
    for j=2:column+1
        temp(i-1,j-1)=abs(2*matrix_en(i,j)-matrix_en(i-1,j)-matrix_en(i+1,j))+abs(2*matrix_en(i,j)-matrix_en(i,j-1)-matrix_en(i,j+1));
    end
end

temp=padarray(temp,[spread spread],'symmetric');
for i=1:row
    for j=1:column
        window=temp(i:1:(i+2*spread),j:1:(j+2*spread));
        cp(i,j)=sqrt(sum(window(:))./(window_wide.^2));
    end
end
% w=[1,1,1;1,1,1;1,1,1];
% cp=imfilter(cp,w,'conv','symmetric','same');
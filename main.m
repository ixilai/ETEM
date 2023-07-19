close all; clear all; clc
addpath function

    img1 = imread('2011CT.png');
    img2 = imread('2011MRI.png');
%%
iter = 3;
p = 0.8;  %0.8
eps = 0.0001; 
%%

img1=im2double(img1);
img2=im2double(img2);
if size(img1,3)>1
    f1=rgb2gray(img1);
else
    f1=im2double(img1);
end
if size(img2,3)>1
    f2=rgb2gray(img2);
else
    f2=im2double(img2);
end
[row,column]=size(f1);
%%
s=3;    r=0.05;   N=4;    T=21; 
%% image decomposition
lambda =3;   npad = 7;  
[LowF1, S1] = lowpass(f1, lambda, npad);
[LowF2, S2] = lowpass(f2, lambda, npad);


%% High frequency fusion
[~, min_gr_ir, max_gr_ir,max_min_ir] = LCP(S1,3);  
[~, min_gr_rgb, max_gr_rgb,max_min_rgb] = LCP(S2,3);  
DM=max(max_gr_ir,max_gr_rgb);
DN=min(min_gr_ir,min_gr_rgb);
EnM = entropy(max_gr_ir);
EnN = entropy(max_gr_rgb);

gamma1 = 0.3 * EnM;
c1 =  max_min_ir * exp(gamma1);
gamma2 = 0.3 * EnN;
c2 =  max_min_rgb * exp(gamma2);

w1=((max_gr_ir.*c1)./(DM-DN));
w2=((max_gr_rgb.*c2)./(DM-DN));
mapp2=abs(w1>=w2);
fuse_High=mapp2.*S1+~mapp2.*S2;  
 figure,imshow(w1,[-1,1]);
 figure,imshow(w2,[-1,1]);
 figure,imshow(fuse_High,[]);


 %%
 Beta_k = 1e-4;
 sorted_si = sort(w1(:),'descend')';
 N = length(sorted_si);
 u = exp(-((0:(N-1))/(N-1))/Beta_k); 
 si = sum(sorted_si.*u)/sum(u);

%%

%map2=zeros(row,column);
SC = calcFocusMeasure_new(LowF1, 3, 'LPC');
SD = calcFocusMeasure_new(LowF2, 3, 'LPC');
map3=abs(SC>SD);
map2=abs(f1>f2);
map1=abs(LowF1>LowF2);
for i=1:row
    for j=1:column
        if map2(i,j)==0 && map3(i,j)==1
            map4(i,j)=1;
        else
            map4(i,j)=map2(i,j);
        end
    end
end


%figure,imshow([map3,map2,map4]);


%%
 map1_guided = guidedfilter(f1, map1, 5, 0.3);  %5 0.3
 map2_guided = guidedfilter(f1, map4, 5, 0.3);
alpha1 = 0.98;  %0.95
alpha2 = 0.9;  %0.95

[h1,h2] = weight_h(map1_guided,map2_guided,alpha1,alpha2);

%%
h1 = h1(:) * 1;
h2 = h2(:) * 1;
sigma = 0.1;  %0.05 
[x1,x2] = solvedirichletboundary(f1,sigma,h1,h2);

FocusMap = zeros(size(map1));
FocusMap(x1 >= x2) = map1_guided(x1 >= x2);
FocusMap(x2 >= x1) = map2_guided(x2 >= x1);

 Gmap=FocusMap;
 GMAP=majority_consist_new(Gmap,9); 
fused_low= GMAP.*LowF1+(1- GMAP).*LowF2;
IF=fused_low+fuse_High;

%%
Lowf = RGFILS(fused_low,1, p, eps, iter);  
W1=LowF1-Lowf;
W2=LowF2-Lowf;
MAP=abs(W1>W2);
MAP=majority_consist_new(MAP,9);
FW=MAP.*W1+(1-MAP).*W2; 
F=FW+Lowf+fuse_High;

  close all

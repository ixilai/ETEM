close all; clear all; clc
addpath function
% addpath 'E:\MATLAB\评价指标\TIP2013-code\function'
% [imagename1, imagepath1]=uigetfile('E:\图像融合\医学图像实验\CT-MRI论文所用图像\CT\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the first input image');
% img1=imread(strcat(imagepath1,imagename1));
% [imagename2, imagepath2]=uigetfile('E:\图像融合\医学图像实验\CT-MRI论文所用图像\MRI\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the first input image');
% img2=imread(strcat(imagepath2,imagename2));


chosen=19;
for ii=1:chosen
%     img1 = imread(['E:\图像融合\医学图像实验\PET-MRI论文所用图像\MRI\new\',num2str(ii),'.PNG']);
%     img2 = imread(['E:\图像融合\医学图像实验\PET-MRI论文所用图像\PET\new\',num2str(ii),'.PNG']);
    img1 = im2double(imread(['E:\图像融合\医学图像实验\黄敬学\源PET-MRI\MRI\',num2str(ii),'.PNG']));
    img2 = im2double(imread(['E:\图像融合\医学图像实验\黄敬学\源PET-MRI\PET\',num2str(ii),'.PNG']));
%     img1 = imread(['E:\图像融合\多模态源图像\多聚焦图像\Lytro\',num2str(2*ii),'.jpg']);
%     img2 = imread(['E:\图像融合\多模态源图像\多聚焦图像\Lytro\',num2str(2*ii-1),'.jpg']);

%%
%lambda = 1;  %1
iter = 3;
p = 0.8;
eps = 0.0001; 
PreFusionPath    = [ 'IMAGE\Ours-PreFus',   num2str(1) , '.jpg' ];
%%

% img1=im2double(img1);
% img2=im2double(img2);
if size(img1,3)>1
    f1=rgb2gray(img1);
else
    f1=im2double(img1);
end
    A_YUV=ConvertRGBtoYUV(img2);   
    f2=A_YUV(:,:,1); 
%figure,imshow([img1,img2]);
[row,column]=size(f1);
%%
%figure,imshow([f1,f2]);
s=3;    r=0.05;   N=4;    T=21; 
%% image decomposition
lambda =3;   npad = 7;  %3 12
[LowF1, S1] = lowpass(f1, lambda, npad);
[LowF2, S2] = lowpass(f2, lambda, npad);
figure,imshow([S1,S2]); figure,imshow([LowF1,LowF2]);
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

w1=((max_gr_ir.*c1)./(DM+DN));
w2=((max_gr_rgb.*c2)./(DM+DN));
mapp2=abs(w1>=w2);
fuse_High=mapp2.*S1+~mapp2.*S2;  
 figure,imshow(mapp2);
% figure,imshow([S1,S2,fuse_High],[]);




%%  Low frequency fusion

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
%figure,imshow([x1,x2]);

FocusMap = zeros(size(map1));
FocusMap(x1 >= x2) = map1_guided(x1 >= x2);
FocusMap(x2 >= x1) = map2_guided(x2 >= x1);

 Gmap=FocusMap;
 GMAP=majority_consist_new(Gmap,9); 
fused_low= GMAP.*LowF1+(1- GMAP).*LowF2;
IF=fused_low+fuse_High;
%%  纹理滤波
Lowf = RGFILS(fused_low,1, p, eps, iter);
W1=LowF1-Lowf;
W2=LowF2-Lowf;
MAP=abs(W1>W2);
MAP=majority_consist_new(MAP,9);
FW=MAP.*W1+(1-MAP).*W2; 
F=FW+Lowf+fuse_High;
F=double(F);

%figure,imshow([F,FW,fused_low,Lowf,fuse_High]);
figure,imshow(Lowf);
%imwrite(F,['E:\图像融合\医学图像实验\论文图像\F.tif']);
%% YUV to RGB
F_YUV=zeros(row,column,3);
F_YUV(:,:,1)=F;
F_YUV(:,:,2)=A_YUV(:,:,2);
F_YUV(:,:,3)=A_YUV(:,:,3);
FF=ConvertYUVtoRGB(F_YUV);          % final fused result    

figure,imshow(FF);
%% IF

% F_YUV=zeros(row,column,3);
% F_YUV(:,:,1)=IF;
% F_YUV(:,:,2)=A_YUV(:,:,2);
% F_YUV(:,:,3)=A_YUV(:,:,3);
% IF=ConvertYUVtoRGB(F_YUV);          % final fused result    






%%



%figure,imshow(D,[]); figure,imshow([F,FF]);
%imwrite(FF,['E:\图像融合\医学图像实验\0 医学 灰度+彩色 实验结果\SPECT-MRI\LXL论文所用方法2\', num2str(ii),'.tif']);
imwrite(FF,['E:\图像融合\医学图像实验\黄敬学\LXL结果\', num2str(ii),'.tif']);

  close all
end
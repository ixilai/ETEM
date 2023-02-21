close all;
clc;
clear all;


% [imagename2, imagepath2]=uigetfile('E:\图像融合\医学图像实验\CT-MRI论文所用图像\MRI\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the first input image');
% Img=imread(strcat(imagepath2,imagename2));
Img=imread('flower.png');
Img=im2double(Img);
lambda=1;
iter = 4;
p = 0.8;
eps = 0.0001; 
f2 = RollingGuidanceFilter(Img,3,0.05,4);
f= RGFILS(Img,lambda, p, eps, iter);
f3 =ILS_LNorm_GPU2(Img, lambda, p, eps, iter);
figure,imshow([Img,f,f2,f3]);
f=double(f);
f3=double(f3);
imwrite(f,['E:\图像融合\医学图像实验\论文图像\my.png']);
%imwrite(f3,['E:\图像融合\医学图像实验\论文图像\ILS.tif']);
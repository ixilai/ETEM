close all; clear all; clc
addpath function

chosen=20;
for ii=1:chosen
    img1 = imread(['E:\图像融合\多模态源图像\多聚焦图像\Lytro\',num2str(2*ii),'.jpg']);
    img2 = imread(['E:\图像融合\多模态源图像\多聚焦图像\Lytro\',num2str(2*ii-1),'.jpg']);
    img1=im2double(img1);
    img2=im2double(img2);

    for i=1:3
        f1=img1(:,:,i);
        f2=img2(:,:,i);
        F(:,:,i)=Lytro(f1,f2);
    end
    figure,imshow(F);
 imwrite(F,['E:\图像融合\多聚焦实验\错误纹理去除\', num2str(ii),'.tif']);
 close all;
end
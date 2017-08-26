clc;clear;close all;
%% read the original image
[pn,fn] = uigetfile('*.jpg;*.bmp;*.png','choose image');%choose the corresponding image(such as 2 to 2)
image = double(imresize(imread([fn pn]),0.04))./255;
figure,imshow(image);
W = 41; %The distance of the filter-window is 20 

% smoothmask = imresize(imread('.\image\Shadow image\2.jpg'),0.5);
% smoothmask = imresize(imread'.\image\Shadow image\4.jpg'),0.5);
smoothmask = imresize(imread('.\image\Shadow image\6.jpg'),0.5);

%% 对hsi颜色空间进行恢复 (EN:recover the shadow region based on hsi colorspace and wallis filter)
hsi = rgb2hsi(image);
h = hsi(:,:,1);
s = hsi(:,:,2);
i = hsi(:,:,3);

i_re = wallisfilter(i,smoothmask,W); % Only recover the i component

result = cat(3,h,s,i_re);
result = hsi2rgb(result);
figure,imshow(result);


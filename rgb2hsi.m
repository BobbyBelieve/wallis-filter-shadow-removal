function hsi=rgb2hsi(image)
%RGB颜色空间
image=im2double(image);
r=image(:,:,1);
g=image(:,:,2);
b=image(:,:,3);
%HSI颜色空间
I=(r+g+b)/3;
tmp1=min(min(r,g),b);
tmp2=r+g+b;
tmp2(tmp2==0)=eps;
S=1-3.*tmp1./tmp2;
tmp1=0.5*((r-g)+(r-b));
tmp2=sqrt((r-g).^2+(r-b).*(g-b));
theta=acos(tmp1./(tmp2+eps));
H=theta;
H(b>g)=2*pi-H(b>g);
H=H/(2*pi);
H(S==0)=0;
hsi=cat(3,H,S,I);
% figure,
% subplot(221),imshow(I1);title('原图');
% subplot(222),imshow(H);title('H');
% subplot(223),imshow(S);title('S');
% subplot(224),imshow(I);title('I');














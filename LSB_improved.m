%% 读取文件信息
img = imread('D:\大三下\数字水印\LSB\lenna.bmp','bmp');
msg = imread('D:\大三下\数字水印\LSB\woman.bmp','bmp');
%% 密钥信息
key = [124564231234609,5487561231231619];

imgsize=size(img);
msgsize=size(msg);
%% 获取载体图像的R,G,B，和二值秘密图像信息。
bitPlaneR=zeros(imgsize(1),imgsize(2),8);
bitPlaneG=zeros(imgsize(1),imgsize(2),8);
bitPlaneB=zeros(imgsize(1),imgsize(2),8);
bitPlaneW=zeros(msgsize(1),msgsize(2));

for i =1:8
    for ro=1:imgsize(1)% ro: row图片行号，y
        for co=1:imgsize(2) %co: column图片,x
        bitPlaneR(ro,co,i)=bitget(img(ro,co,1), i);
        bitPlaneG(ro,co,i)=bitget(img(ro,co,2), i);
        bitPlaneB(ro,co,i)=bitget(img(ro,co,3), i);
        end        
    end    
end

for ro=1:msgsize(1)
    for co=1:msgsize(2)
    bitPlaneW(ro,co)=bitget(msg(ro,co), 1);
    end        
end     

Chaos_array = chaos(3.90,0.1);
[~, index] = sort(Chaos_array, 'ascend');

for i=1:256
    for j=1:256
        bias = bitshift(img(i,j),-4);
        flag1 = mod(mod(key(1),bias),4)+1;
        flag2 = mod(mod(key(2),bias),3)+1;
        if flag2==1
            bitPlaneR(i,j,flag1) = bitPlaneW(index(256*(i-1)+j));
        end
        if flag2==2
            bitPlaneG(i,j,flag1) = bitPlaneW(index(256*(i-1)+j));
        end
        if flag2==3
            bitPlaneB(i,j,flag1) = bitPlaneW(index(256*(i-1)+j));
        end
    end 
end

%% 合成秘密图像

newbitPlane=zeros(256,256,3);

for i=1:8
    newbitPlane(:,:,1) = newbitPlane(:,:,1)+bitPlaneR(:,:,i)*2^(i-1);
end

for i=1:8
    newbitPlane(:,:,2) = newbitPlane(:,:,2)+bitPlaneG(:,:,i)*2^(i-1);
end

for i=1:8
    newbitPlane(:,:,3) = newbitPlane(:,:,3)+bitPlaneB(:,:,i)*2^(i-1);
end

%% 噪声

newbitPlane = uint8(newbitPlane);

% 1.添加色块
%{
for i=1:50
    for j=1:50
        newbitPlane(i,j,:)=0;
    end
end
%}

d = 0.01;
% 2. 高斯噪声
% newbitPlane=imnoise(newbitPlane, 'gaussian', 0, d);
% 3. 椒盐噪声
% newbitPlane=imnoise(newbitPlane, 'salt & pepper', d);
% 3. 泊松噪声
% newbitPlane=imnoise(newbitPlane, 'poisson');
% 4. 乘性噪声
% newbitPlane=imnoise(newbitPlane, 'speckle', d);

%% 拆分秘密图像

for i =1:8
    for ro=1:imgsize(1)% ro: row图片行号，y
        for co=1:imgsize(2) %co: column图片,x
        bitPlaneR(ro,co,i)=bitget(newbitPlane(ro,co,1), i);
        bitPlaneG(ro,co,i)=bitget(newbitPlane(ro,co,2), i);
        bitPlaneB(ro,co,i)=bitget(newbitPlane(ro,co,3), i);
        end        
    end    
end

%% 提取隐藏信息
Msg = zeros(256,256);
for i=1:256
    for j=1:256
        bias = bitshift(img(i,j),-4);
        flag1 = mod(mod(key(1),bias),4)+1;
        flag2 = mod(mod(key(2),bias),3)+1;
        if flag2==1
            Msg(index(256*(i-1)+j)) = bitPlaneR(i,j,flag1);
        end
        if flag2==2
            Msg(index(256*(i-1)+j)) = bitPlaneG(i,j,flag1);
        end
        if flag2==3
            Msg(index(256*(i-1)+j)) = bitPlaneB(i,j,flag1);
        end
    end 
end

%% 展示图像
subplot(1,2,1)
imshow(uint8(newbitPlane))
title('载体图像')
imwrite(uint8(newbitPlane),'Msg.bmp'); %存储灰度图像
subplot(1,2,2)
imshow(uint8(255*Msg))
title('秘密信息')
function result = wallisfilter(gray,shadow,W)
% function is used to recover the shadow region based on IOBA algorithm and
% wallis filter
% gray 输入的灰度图 (EN:import image 2-D)
% shadow 检测出来的阴影区域,高斯卷积后的阴影区域 (EN:the shadow region BW image)
% W wallis滤波窗口的大小 (EN:The size of the window with wallis filter)

shadow = imbinarize(shadow);
se = strel('disk',3);
result = gray;
x = size(shadow,1);
y = size(shadow,2);
ex_shadow = zeros(x+W-1,y+W-1);%给shadow补零
ex_shadow(round(W/2):x + floor(W/2),round(W/2):y + floor(W/2)) = shadow;
IBA = logical(ex_shadow - imerode(ex_shadow,se));
IBA_j = IBA;%用来判断循环是否继续的条件
OBA = logical(imdilate(ex_shadow,se) - ex_shadow);
gray_mask = zeros(x+W-1,y+W-1);
gray_mask(round(W/2):x + floor(W/2),round(W/2):y + floor(W/2)) = result;%后面有补零后的O_mask与gray相乘的情况，需要相同的矩阵大小。
m = size(gray_mask,1);n = size(gray_mask,2);
num = 0;
while sum(sum(IBA_j)) > 0 || sum(sum(ex_shadow)) > 0 %针对阴影区域太小，内检查线被腐蚀的情况，添加了sum(sum(shadow))的判断条件。
    num = num + 1;
    if sum(sum(IBA_j)) == 0 && sum(sum(ex_shadow)) > 0
        if sum(sum(ex_shadow)) > sum(sum(se.Neighborhood))
            OBA = imdilate(ex_shadow,se) - ex_shadow;
            IBA = ex_shadow - imerode(ex_shadow,se);
            IBA_j = IBA;
        else
            OBA = imdilate(ex_shadow,se) - ex_shadow;
            IBA = ex_shadow;
            IBA_j = IBA;
        end
    end
    for i = 1:m
        for j = 1:n
            if IBA_j(i,j) == 1
                O_mask = zeros(m,n);
                I_mask = zeros(m,n);
                for k = i - floor(W/2) : i + floor(W/2)
                    for l = j - floor(W/2) : j + floor(W/2)
                        if gray_mask(i,j) > gray_mask(k,l)
                            O_mask(k,l) = 0;
                            I_mask(k,l) = 1;
                        else
                            O_mask(k,l) = 1;
                            I_mask(k,l) = 1;
                        end
                    end
                end
                % 分别计算内外检查线内均值与标准差
                O_mask = O_mask .* OBA;%分别对应内外检查线元素
                I_mask = I_mask .* IBA;
                U_Omask = sum(sum(O_mask.*gray_mask))/sum(sum(O_mask));
                U_Imask = sum(sum(I_mask.*gray_mask))/sum(sum(I_mask));
                % 分别计算内外检查线内标准方差
                S_OBA = (gray_mask.*O_mask - U_Omask*O_mask).^2;
                S_OBA = sqrt(sum(sum(S_OBA))/sum(sum(O_mask)));
                S_IBA = (gray_mask.*I_mask - U_Imask*I_mask).^2;
                S_IBA = sqrt(sum(sum(S_IBA))/sum(sum(I_mask)));
                if sum(sum(O_mask)) == 0
                    re = result(i-floor(W/2),j-floor(W/2));
                    result(i-floor(W/2),j-floor(W/2)) = re;
                    gray_mask(i,j) = re;
                    IBA_j(i,j) = 0;ex_shadow(i,j) = 0;
                elseif sum(sum(O_mask)) ~= 0
                    re = U_Omask + (round(result(i-floor(W/2),j-floor(W/2))-U_Imask)) * S_OBA/S_IBA;
                    result(i-floor(W/2),j-floor(W/2)) = re;
                    gray_mask(i,j) = re;
                    IBA_j(i,j) = 0;ex_shadow(i,j) = 0;
                elseif IBA(i,j) == 0 && sum(sum(IBA_j)) == 0
                    break;
                end
            end
        end
    end
end
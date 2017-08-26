function result = wallisfilter(gray,shadow,W)
% function is used to recover the shadow region based on IOBA algorithm and
% wallis filter
% gray ����ĻҶ�ͼ (EN:import image 2-D)
% shadow ����������Ӱ����,��˹��������Ӱ���� (EN:the shadow region BW image)
% W wallis�˲����ڵĴ�С (EN:The size of the window with wallis filter)

shadow = imbinarize(shadow);
se = strel('disk',3);
result = gray;
x = size(shadow,1);
y = size(shadow,2);
ex_shadow = zeros(x+W-1,y+W-1);%��shadow����
ex_shadow(round(W/2):x + floor(W/2),round(W/2):y + floor(W/2)) = shadow;
IBA = logical(ex_shadow - imerode(ex_shadow,se));
IBA_j = IBA;%�����ж�ѭ���Ƿ����������
OBA = logical(imdilate(ex_shadow,se) - ex_shadow);
gray_mask = zeros(x+W-1,y+W-1);
gray_mask(round(W/2):x + floor(W/2),round(W/2):y + floor(W/2)) = result;%�����в�����O_mask��gray��˵��������Ҫ��ͬ�ľ����С��
m = size(gray_mask,1);n = size(gray_mask,2);
num = 0;
while sum(sum(IBA_j)) > 0 || sum(sum(ex_shadow)) > 0 %�����Ӱ����̫С���ڼ���߱���ʴ������������sum(sum(shadow))���ж�������
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
                % �ֱ�������������ھ�ֵ���׼��
                O_mask = O_mask .* OBA;%�ֱ��Ӧ��������Ԫ��
                I_mask = I_mask .* IBA;
                U_Omask = sum(sum(O_mask.*gray_mask))/sum(sum(O_mask));
                U_Imask = sum(sum(I_mask.*gray_mask))/sum(sum(I_mask));
                % �ֱ�������������ڱ�׼����
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
I=imread(Image1.png');
I=double(rgb2gray(I));
F=makeRFSfilters; 
[Left,Right]=CreateHalfMasks();

for count=1:size(F,3)
    Id(:,:,count)=imfilter(I,F(:,:,count));
end

X=zeros(size(I,1)*size(I,2),size(F,3));
for count=1:size(X,2)
    Y=Id(:,:,count);
    X(1:size(X,1),count)=Y(:);
end 

k=64; [idx,C]=kmeans3(X,k); 

%Creating texton map
Textons=zeros(size(I,1),size(I,2));
for count=1:size(I,1)
    for count1=1:size(I,2)
        Textons(count,count1)=idx(sub2ind(size(Textons),count,count1));
    end
end 

figure, image(Textons); colormap gray;
title('texton map')

%Computing texton gradient(tg)
constant=0.01;
chi_sqr=zeros(size(Textons,1),size(Textons,2));
for count1=1:size(Left,3)
    for count=1:k
        tmp=(Textons==count);
        g_i=conv2(double(tmp),Left(:,:,count1),'same');
        h_i=conv2(double(tmp),Right(:,:,count1),'same');
        chi_sqr(:,:)=chi_sqr(:,:)+0.5*(g_i-h_i).^2 ./ (g_i+h_i+constant);
    end
end

%Computing brightness gradient(bg)
chi_sqr_=zeros(size(I,1),size(I,2));
for count1=1:size(Left,3)
    for count=1:8:256
        tmp=(I==count-1);
        g_i=conv2(double(tmp),Left(:,:,count1),'same');
        h_i=conv2(double(tmp),Right(:,:,count1),'same');
        chi_sqr_(:,:)=chi_sqr_(:,:)+0.5*(g_i-h_i).^2 ./ (g_i+h_i+constant);
    end
end


%Implementing Canny edge detector
sigma=linspace(1,6,11);
Canny1=edge(I,'canny',0.4,'both',4);
Canny2=edge(I,'canny',0.3,'both',3);
Canny3=edge(I,'canny',0.7,'both',2);
Canny4=edge(I,'canny',0.2,'both',1.5);
Canny5=edge(I,'canny',0.8,'both',1)/5;
I1 = Canny1+Canny2+Canny3+Canny4+Canny5;
figure, imagesc(I1);
colormap gray
title('Canny edge')

%Implementing pb edge detector
q=0.61;
I2=zeros(size(I,1),size(I,2));
for count=1:size(I,1)
    for count1=1:size(I,2)
        I2(count,count1)=I1(count,count1)*((1-q)*chi_sqr(count,count1)+q*chi_sqr_(count,count1,:));
    end
end
figure, image(I2);
colormap gray
title('pb detector')

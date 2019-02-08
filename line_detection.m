%This is going to be turned into a function

testimg = cell2mat(examscripts(1));

%k-means colour segmentation, to seperate foreground/background
k_img = kmeanscolourseg(testimg,2,20);

figure(7)
imshow(k_img)

%Plot histogram of RGB channels of k-means image
figure(8)
R=imhist(k_img(:,:,1));
G=imhist(k_img(:,:,2));
B=imhist(k_img(:,:,3));
figure, plot(R,'r')
hold on, plot(G,'g')
plot(B,'b'), legend(' Red channel','Green channel','Blue channel');
hold off, 

%analyse seperation of foreground/background in HSV channel
hsv = rgb2hsv(k_img);

figure(9)
H=imhist(hsv(:,:,1)); %hue
S=imhist(hsv(:,:,2)); %saturation
V=imhist(hsv(:,:,3)); %value
figure, plot(H,'r')
hold on, plot(S,'g')
plot(V,'b'), legend('Hue','Saturation','Value');
hold off

%work with Hue channel for seperation
Hue = hsv(:,:,1);

mask = Hue > (max(max(Hue)) + min(min(Hue))) / 2;

h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);

%make image white in mask areas
h(mask) = 0;
s(mask) = 0;
v(mask) = 1; %white (object pixels)
v(~mask) = 0; %black (background)

hsvImage = cat(3, h, s, v);
newRGB = hsv2rgb(hsvImage);

%remove noise in image and blend missclassified background pixels in with
%foreground
%close then open
gray = rgb2gray(newRGB);
BW = imbinarize(gray);

figure(10) 
subplot(1,3,1)
imshow(BW);
hold on
subplot(1,3,2)
se = strel('disk',10); %circular structuring element
temp = imclose(BW, se);

imshow(temp);

subplot(1,3,3)
temp2 = imopen(temp, se);

imshow(temp2);
hold off
%testimg = rgb2gray(testimg);

%{
BW = edge(testimg, 'canny');

figure(1)
imshow(testimg)

figure(2)
imshow(BW)
%}
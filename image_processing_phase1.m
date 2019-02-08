%This is going to be turned into a function

for i=1:length(examscripts)
    
    img = cell2mat(examscripts(i));
    backgroundless_scripts{i} = blackout_background(img, 2);
    fprintf('%d / %d \n ', i, length(examscripts))

end

function [I] = blackout_background(img, nColours)

%k-means colour segmentation, to seperate foreground/background
k_img = kmeanscolourseg(img,nColours,20);

%analyse seperation of foreground/background in HSV channel
hsv = rgb2hsv(k_img);

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

se = strel('disk',10); %circular structuring element
temp = imclose(BW, se);

%imshow(temp);

%subplot(1,3,3)
temp2 = imopen(temp, se);

% Connected Componenets
CC = bwconncomp(temp2);

%remove anything thats not largest component
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);

for k=1:length(CC.PixelIdxList)
    if k ~= idx
       temp2(CC.PixelIdxList{k}) = 0; 
    end
end

I = mask_image(img, temp2);

    function [I_masked] = mask_image(I, mask)

        I_masked = I;

        [rows, cols, channels] = size(I);

        for c=1:channels
            for i=1:rows
               for j=1:cols

                   if mask(i, j) == 0
                      I_masked(i, j, c) = 0; 
                   end

               end
           end
        end
    end

end
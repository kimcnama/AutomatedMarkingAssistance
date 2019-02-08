
%To show images in array
bluesheet= cell2mat(examscripts(1));
figure(8)
imshow(bluesheet)

figure(9)
whitesheet = cell2mat(examscripts(11));
imshow(whitesheet)

yblue = bluesheet(:,:,3);
ywhite = whitesheet(:,:,3);

[histblueB, x] = imhist(yblue);
[histwhiteB, x] = imhist(ywhite);

figure(10)
subplot(1,2,1), imshow(yblue, [0, 255])
subplot(1,2,2), imshow(ywhite, [0, 255])

yblue = bluesheet(:,:,2);
ywhite = whitesheet(:,:,2);

[histblueG, x] = imhist(yblue);
[histwhiteG, x] = imhist(ywhite);

figure(11)
subplot(1,2,1), imshow(yblue, [0, 255])
subplot(1,2,2), imshow(ywhite, [0, 255])

yblue = bluesheet(:,:,1);
ywhite = whitesheet(:,:,1);

figure(12)
subplot(1,2,1), imshow(yblue, [0, 255])
subplot(1,2,2), imshow(ywhite, [0, 255])

[histblueR, x] = imhist(yblue);
[histwhiteR, x] = imhist(ywhite);

figure(13)
plot(x, histblueB, 'blue', x, histwhiteB, 'cyan')
figure(14)
plot(x, histblueG, 'green', x, histwhiteG, 'yellow')
figure(15)
plot(x, histblueR, 'red', x, histwhiteR, 'magenta')


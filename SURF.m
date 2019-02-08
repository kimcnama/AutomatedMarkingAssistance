
%template = rgb2gray(template);
testimage = rgb2gray(cell2mat(examscripts(11)));

points = detectSURFFeatures(template);
points2 = detectSURFFeatures(testimage);

figure(1)
imshow(template); 
hold on;
plot(points.selectStrongest(100));
hold off

figure(2)
imshow(testimage); 
hold on;
plot(points2.selectStrongest(100));
hold off

%extract features
[f1,vpts1] = extractFeatures(template,points);
[f2,vpts2] = extractFeatures(testimage,points2);

%locations of matched features
indexPairs = matchFeatures(f1,f2);
matchedPoints1 = vpts1(indexPairs(:,1));
matchedPoints2 = vpts2(indexPairs(:,2));

figure(4); 
showMatchedFeatures(template,testimage,matchedPoints1,matchedPoints2, 'montage');
legend('matched points 1','matched points 2');



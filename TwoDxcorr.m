

%exam = rgb2gray(imread('~/mai_project_media/cropped_template.jpg'));

for i=1:26
    
exam = rgb2gray(backgroundless_scripts{i});
template = rgb2gray(imread('~/mai_project_media/grades_fields.jpg'));

disp(size(template))
template=imresize(template, 0.5);
disp(size(template))

c = normxcorr2(template, exam);

figure, surf(c), shading flat

[ypeak, xpeak] = find(c==max(c(:)));
 
yoffSet = ypeak-size(template,1);
xoffSet = xpeak-size(template,2);

figure
imshow(exam);
hold on
h = imrect(gca, [xoffSet+1, yoffSet+1, size(template,2), size(template,1)]);
hold off

pause
close all

end
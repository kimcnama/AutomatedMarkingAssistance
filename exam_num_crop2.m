%TEMPLATE MATCHING

template = rgb2gray(imread('~/mai_project_media/exam_number_field.jpg'));
n_resizes = 10;

s.max = -9999;
s.max_pic = template;

for i=1:length(exam_info)   
    for j=1:n_resizes
        try
            close all

            exam = exam_info{i}.exam_number;

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
        catch
            continue
        end
        template = imresize(template, 0.9);
    end
end
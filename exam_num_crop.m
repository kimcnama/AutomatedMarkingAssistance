close all

%for i=1:length(exam_info)
i=1;
   exam_number = exam_info{i}.cropped_examnum;
   
   figure
   subplot(6, 1, 1)
   imshow(exam_number(:,:,1))
   [im, em1] = graythresh(exam_number(:,:,1));
   
   subplot(6, 1, 2)
   imshow(exam_number(:,:,2))
   [im, em2] = graythresh(exam_number(:,:,2));
   subplot(6, 1, 3)
   imshow(exam_number(:,:,3))
   [im, em3] = graythresh(exam_number(:,:,3));
   
   subplot(6, 1, 4)
   imhist(exam_number(:,:,1))
   hold on 
   plot ([em1*256 em1*256], [0, max(imhist(exam_number(:,:,1)))])
   hold off
   subplot(6, 1, 5)
   imhist(exam_number(:,:,2))
   hold on 
   plot ([em2*256 em2*256], [0, max(imhist(exam_number(:,:,2)))])
   hold off
   subplot(6, 1, 6)
   imhist(exam_number(:,:,3))
   hold on
   plot ([em3*256 em3*256], [0, max(imhist(exam_number(:,:,3)))])
   hold off
   
   
   figure;
   pd = fitdist(imhist(exam_number(:,:,3)));
   %{
   blur = imgaussfilt(exam_number,1.5);
   
   bw = imbinarize(blur);
   
   C = corner(bw);
   
   subplot(2,1,1)
   imshow(exam_number)
   
   subplot(2,1,2)
   imshow(bw);
   hold on 
   plot(C(:,1),C(:,2),'r*');
   pause
    %}
%end
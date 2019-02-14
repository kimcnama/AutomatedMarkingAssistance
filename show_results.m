for i=1:length(exam_info)
    
    figure(1); imshow(exam_info{i}.cropped_examnum)
    figure(2); imshow(exam_info{i}.cropped_grades)
    pause
end  
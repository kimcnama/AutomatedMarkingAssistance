stats2 = {};

for i=1:length(exam_info)
   
    close all
    examscript = exam_info{i}.cropped_grades;    
    
    bw = imbinarize(examscript); 
    
    se = strel('rectangle', [3, 3]);
    bw = imopen(bw, se);
    
    bw = ~bw;
    imshow(bw)
    
    % find both black and white regions
    stats = [regionprops(bw); regionprops(not(bw))];
    
    pic_area = size(bw);
    pic_area = pic_area(1) * pic_area(2);
    
    % show the image and draw the detected rectangles on it
    valid_stats_count = 1;
    figure(1); 
    imshow(bw); 
    hold on;
    for r = 1:numel(stats)
        rectangle('Position', stats(r).BoundingBox, ...
            'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
        
        %only include valid rectangles
        if stats(r).Area <= 0.4*pic_area && stats(r).Area >= 0.001*pic_area
            stats2{valid_stats_count} = stats(r);
            valid_stats_count = valid_stats_count + 1;
        end
    end
    
    figure(2); 
    imshow(bw); 
    hold on;
    
    %draw valid rectangles
    for r = 1:length(stats2)
        
            rectangle('Position', stats2{r}.BoundingBox, ...
            'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
        drawnow   
    end
    
    stats = stats2;
    
    most_overlap_rect_index = 0;
    max_overlap_area = 0;
    
    %extract rectangle with most overlap. Grades boxes have lots of boxes
    %as it is grid so should always have largest total area of overlap
    for r=1:length(stats2)
        
       total_overlap_area = 0;
       for rr=1:length(stats2)
          
           if rr ~= r
               total_overlap_area = total_overlap_area + ...
                   rectint(stats2{r}.BoundingBox, stats2{rr}.BoundingBox);
                if total_overlap_area > max_overlap_area
                    max_overlap_area = total_overlap_area;
                    most_overlap_rect_index = r;
                end
           end
           
       end
        
    end
    figure(3);
    imshow(bw);
    hold on;
    rectangle('Position', stats2{most_overlap_rect_index}.BoundingBox, ...
            'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
    drawnow
    figure(4);
    imshow(imcrop(examscript, stats2{most_overlap_rect_index}.BoundingBox));
    pause
end


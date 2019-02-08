areas_extracted = [];
%ground truth = [442 12 589 69] -- [x y w h]
aspect_ratio = 589 / 69; % width / height

for i=1:length(exam_info)   

    fprintf('\nIteration %d / %d \n', i, length(examscripts))
    
    close all
    exam_number = exam_info{i}.exam_number;
    BW = imgaussfilt(exam_number, 1.5);
    figure(3);imshow(BW);
    BW = edge(BW,'canny');
    
    %DETECT HOUGH LINES
    [H,T,R] = hough(BW);
   
    imshow(H,[],'XData',T,'YData',R,...
                'InitialMagnification','fit' );
    xlabel('\theta'), ylabel('\rho');
    axis on, axis normal, hold on;
    
    P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
    x = T(P(:,2)); y = R(P(:,1));
    plot(x,y,'s','color','white');
    
    lines = houghlines(BW,T,R,P,'FillGap',2,'MinLength',10);
    figure, imshow(exam_number), hold on
    max_len = 0;
    max_theta = 0;
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

       % Determine the endpoints of the longest line segment
       len = norm(lines(k).point1 - lines(k).point2);
       if ( len > max_len)
          max_len = len;
          xy_long = xy;
          max_theta = lines(k).theta;
       end
    end 
   close all
   max_theta = 90 + max_theta;
   
   if abs(max_theta) >= 90
      max_theta = max_theta - 180; 
   end
   
   exam_info{i}.max_theta = max_theta;
   exam_info{i}.tot_rotation = max_theta + exam_info{i}.rotation;
   
   plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','cyan');
   exam_number = exam_info{i}.exam_number;
   exam_number = imrotate(exam_number, max_theta, 'bicubic', 'crop');
   exam_info{i}.exam_number = exam_number;
   BW = imgaussfilt(exam_number, 1.5);
   bw = edge(BW,'canny');
   
   se = strel('rectangle', [1 , 5]);
   figure(12); imshow(imclose(bw, se))
   bw = imclose(bw, se);
   
   tot_pic_area = size(exam_number);
   tot_pic_area = tot_pic_area(1) * tot_pic_area(2); 
   
   %DETECT RECTANGLES
   stats = [regionprops(bw); regionprops(not(bw))];
   figure(1)
   imshow(bw); 
    hold on;
    stats2 = {};
    
    %FILTER OUT BAD RECTANGLES
    for r = 1:numel(stats)
        
        ar = stats(r).BoundingBox(3) / stats(r).BoundingBox(4);
        
        if stats(r).Area < tot_pic_area * 0.3 && stats(r).Area > tot_pic_area * 0.005 ...
                && ar > aspect_ratio*0.5 ...
                && ar < aspect_ratio*1.1
            
            stats2{length(stats2) + 1} = stats(r);   
            rectangle('Position', stats(r).BoundingBox, ...
            'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
        end
        if r == length(stats) && length(stats2) == 0
           exam_info{i}.flag = 1; 
        end
    end
    
    %UPDATE STATS
    stats = stats2;
    exam_info{i}.stats = stats;
    close(12) 
    
    %CHOOSE BEST OF FINAL RECTANGLES
    rect_index = 0; %if 0 then no rectangle found
    
    if exam_info{i}.flag == 0
        
        min_difference = 99999999999999;
        
        
        
        for r=1:length(stats)
            ar = stats{r}.BoundingBox(3) / stats{r}.BoundingBox(4);
            if abs(aspect_ratio - ar) < min_difference
                min_difference = abs(aspect_ratio - ar);
                crop_rect = stats{r}.BoundingBox;
                rect_index = r;
            end
        end 
        
        figure(2)
        first_examnum_crop = imcrop(exam_number, crop_rect);
        imshow(first_examnum_crop);
        exam_info{i}.first_examnum_crop = first_examnum_crop;
    else
        exam_info{i}.first_examnum_crop = exam_number;
    end
    areas_extracted = [areas_extracted; ...
                    (crop_rect(3)*crop_rect(4)), rect_index];
  
end

%calculate median area and extract, area closest to median area
median_area_extracted = median_rect_area(areas_extracted);

for i=1:length(exam_info)
   
    stats = exam_info{i}.stats;
    exam_number = exam_info{i}.exam_number;
    boxes_found = 0;
    
    min_area_diff = 9999999999999;
    for s=1:length(stats)
        if abs(stats{s}.Area - median_area_extracted) < min_area_diff
            min_area_diff = abs(stats{s}.Area - median_area_extracted);
            boxes_found = 1;
            crop_rect = stats{s}.BoundingBox;
        end
    end
    if boxes_found == 1
        cropped_exam_number = imcrop(exam_number, crop_rect);
        figure(4); 
        imshow(exam_info{i}.exam_number)
        exam_info{i}.cropped_exam_number = cropped_exam_number;
        figure(2)
        imshow(exam_info{i}.first_examnum_crop)
        figure(3)
        imshow(cropped_exam_number)
    end
     pause
end


function [med] = median_rect_area(areas_extracted)
    
    relevant_areas = [];
    for k=1:length(areas_extracted(:,2))
        if areas_extracted(k, 2) ~= 0
            relevant_areas = [relevant_areas; areas_extracted(k, 1)];
        end
    end
    med = median(relevant_areas);
end
close all
clc

%ground truth = [520 527 1122-520 612-527]
aspect_ratio = (1122-520)/(612-527); %width/height

for j=1:length(exam_info)

close all
   exam_number = rgb2gray(exam_info{j}.cropped_examnum);
   
   exam_number = imadjust(exam_number,stretchlim(exam_number),[]);
   
   bw = edge(exam_number,'canny');
   %figure(3);
   %imshow(bw)
   
   stats = [regionprops(bw); regionprops(not(bw))]; 
   
   tot_pic_area = size(exam_number, 1) * size(exam_number, 2);
   
   stats2 = {};
   inserted = 1;
    hold on;  
    for r = 1:numel(stats)
        
        ar = stats(r).BoundingBox(3) / stats(r).BoundingBox(4);
        area = stats(r).BoundingBox(3) * stats(r).BoundingBox(4);
        
        if area < tot_pic_area * 0.9 && area > tot_pic_area * 0.005 ...
                && ar > aspect_ratio*0.6 ...
                && ar < aspect_ratio*1.2
             
            stats2{inserted} = stats(r);
            inserted = inserted + 1;
            %rectangle('Position', stats(r).BoundingBox, ...
            %'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
        
        end
    end
    
    if length(stats2) > 1
        max_area = stats2{1}.Area;
        max_area_ind = 1;
        for r=2:length(stats2)
            if stats2{r}.Area > max_area
                max_area = stats2{r}.Area;
                max_area_ind=r;
            end
        end
        stats = stats2{max_area_ind};
        stats2 = {};
        stats2{1} = stats;
    end
    
    if length(stats2) < 1
        exam_info{j}.flag = 1;
        fprintf('\n flag activated for index: %d \n', j);
    else    
        exam_info{j}.cropped_examnum2 = imcrop(exam_number, stats2{1}.BoundingBox);
    end
    
end

close all
%split exam number up
for i=1:length(exam_info) 
%i=3;

    %if exam_info{i}.flag == 0
    
        exam_number = exam_info{i}.cropped_examnum2;
        
        BW = ~imbinarize(exam_number);
        
        %DETECT HOUGH LINES
    [H,T,R] = hough(BW);
    
    P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
    x = T(P(:,2)); y = R(P(:,1));
    
    lines = houghlines(BW,T,R,P,'FillGap',2,'MinLength',10);
    max_len = 0;
    max_theta = 0;
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];

       % Determine the endpoints of the longest line segment
       len = norm(lines(k).point1 - lines(k).point2);
       if ( len > max_len)
          max_len = len;
          xy_long = xy;
          max_theta = lines(k).theta;
       end
    end 
    
    gray_exam_number = imrotate(exam_number, abs(max_theta) -90 ,'bilinear', 'loose');
    exam_number = imrotate(BW, abs(max_theta) -90 ,'bilinear', 'loose');
    
    stats = [regionprops(exam_number); regionprops(not(exam_number))];
    % show the image and draw the detected rectangles on it
    
    [avoid_rects_i, stats] = largest_two_areas(stats);
    
    stats2={};
    inserted = 1;
    tot_pic_area = size(exam_number, 1)*size(exam_number, 2);
    
    %x_diff/y_diff = 116/66
    aspect_ratio = 1.758;
    
    for r=1:length(stats)
        if stats(r).Area < 0.9*tot_pic_area
            if ~(r == avoid_rects_i(1) || r == avoid_rects_i(2))
                ar = stats(r).BoundingBox(3)/stats(r).BoundingBox(4);
                if ar < 1.1*aspect_ratio && ar > 0.7*aspect_ratio
                    stats2{inserted} = stats(r);
                    inserted = inserted + 1;
                end
            end
        end
    end
    
    %remove rects that are completely inside other rects
    stats={};
    inserted = 1;
    
    for r=1:length(stats2)
        in_another_rect = false;
       for rr=1:length(stats2)
          if r ~= rr
              if rectA_contained_in_rectB(stats2{r}.BoundingBox, stats2{rr}.BoundingBox) == true
                  in_another_rect = true;
              end
          end
       end
       if in_another_rect == false
           stats{inserted} = stats2{r};
           inserted = inserted + 1;
       else
           disp('Rect lay in another rect so ignored')
       end
    end
    
    imshow(exam_number); 
    hold on;

    for r = 1:length(stats)        
            rectangle('Position', stats{r}.BoundingBox, ...
            'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
    end 
   
   pause
   close all
   
   if length(stats) < 5
      exam_info{i}.flag = 1;
      fprintf('Flag turned on for index: %d \n', i);
   else
       
   end
   
   %end
end

function [vector, stats] = largest_two_areas(stats)
    
    max_area = [1;2];
    vector = [0;0];
    
    for r = 1:numel(stats)
        area = stats(r).BoundingBox(3)*stats(r).BoundingBox(4);
        stats(r).Area = area;
        if area > min(max_area)  
            
            ind = find(max_area==min(max_area));
            max_area(ind) = stats(r).Area;
            vector(ind) = r;
        end
    end

end
 
function [bool] = rectA_contained_in_rectB(rectA, rectB)
    bool = false;
    
    %check x's
    if rectA(1) > rectB(1) && (rectA(1)+rectA(3)) < (rectB(1)+rectB(3))
        if rectA(2) > rectB(2) && (rectA(2)+rectA(4)) < (rectB(2)+rectB(4))
            bool = true;
        end
    end
end



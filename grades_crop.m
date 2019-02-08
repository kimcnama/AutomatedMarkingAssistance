%TRY TO EXTRACT GRADES FROM APPROACH 2

%crop and rotate
for i=1:length(exam_info)

    fprintf('\nIteration %d / %d \n', i, length(examscripts))
    
   examscript = rgb2gray(exam_info{i}.original);
   
   examscript = imrotate(examscript, exam_info{i}.tot_rotation, 'bicubic', 'crop');
   
   crop_rect = crop_out_black(examscript);
   
   examscript = imcrop(examscript, crop_rect);
   
   %template always first image!!!
   %mean_position [x y]
   [num, locs, mean_position] = match(grades_fields, examscript, false);
   close all
   [rows, cols] = size(examscript); 
   
   %[x y w h]
   %cut 6/7 s of the way up to the mean position of page 
   crop_rect = [(6*(mean_position(1)) / 7) (6*(mean_position(2)) / 7) ...
       cols - ceil(mean_position(1) / 2)  ...
       rows - ceil(mean_position(2) / 2) ];
  
   examscript = imcrop(examscript, crop_rect);
   
   %set black background region to avg background colour
   mean_pixel_intensity = mean_pixel_value(examscript);
   
    BW = imgaussfilt(examscript, 1.5);
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
    figure, imshow(examscript), hold on
    
    %list of rotation angles 
    rot_angles = [];
    
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

       if abs(lines(k).theta) <= 45
           rot_angles = [rot_angles lines(k).theta];
       end
    end 
    
   examscript = imrotate(examscript, median(rot_angles), 'bicubic', 'crop');
   
   %must remove black background from rotation, messing up binary image
   %conversion
   bw = custom_binary_image(examscript);
   bw = im2bw(bw);
   
   %erode image because of bicubic interpolation from rotation (gradual edge changes)
   se = strel('cube', 17);
   bw = imerode(bw, se);
   
   examscript = gray_mask_image(examscript, bw); 
   
   examscript = change_black_regions(examscript, mean_pixel_intensity);
   
   %figure(1); imshow(examscript); pause;
   
   exam_info{i}.cropped_grades = examscript;
   close all
end

function [I_masked] = gray_mask_image(I, mask)

        I_masked = I;

        [rows, cols] = size(I);
     
            for i=1:rows
               for j=1:cols

                   if mask(i, j) == 0
                      I_masked(i, j) = 0; 
                   end

               end
           end
        
end

function [J] = custom_binary_image(I)
    
    J=I;
    
    [cols, rows] = size(J);
    
    for r=1:rows
       for c=1:cols
          if I(c, r) == 0
              J(c, r) = 0;
          else
              J(c, r) = 255;
       end        
    end

    end
end

function [med] = mean_pixel_value(I)
    
    intensities = [];
    
    [cols, rows] = size(I);
    
    for i=1:rows
       for j=1:cols
          if I(j, i) > 0 
              intensities = [intensities I(j, i)];
          end
       end
    end
    med = floor(mean(intensities));
end

function [J] = change_black_regions(I, med)
    
    J = I;
    [cols, rows] = size(I);
    
    for i=1:rows
       for j=1:cols
          if J(j, i) < 1 
              J(j, i) = med;
          end
       end
    end
    
end

function [rect] = crop_out_black(I)

    left_edge = 0;
    top_edge = 0;
    bottom_edge = 0;
    right_edge = 0;
    
    [cols, rows] = size(I);
    
    %left edge
    for i=1:rows
       left_edge = i;
       if sum(I(:, i)) > 0
           break
       end
    end
    
    %right edge
    for i=rows:-1:1
       right_edge = i;
       if sum(I(:, i)) > 0
           break
       end
    end
    
    %top edge
    for j=1:cols
       top_edge = j;
       if sum(I(j, :)) > 0
           break
       end
    end
    
    %bottom edge
    for j=cols:-1:1
       bottom_edge = j;
       if sum(I(j, :)) > 0
           break
       end
    end
    
    % [x y w h]
    rect = [left_edge top_edge (right_edge - left_edge) (bottom_edge - top_edge)];
end




%TRY TO EXTRACT GRADES FROM ATTEMPT 1

crop_offset = 100;

for i=1:length(exam_info)
    
    examscript = rgb2gray(exam_info{i}.original);
    
    dimensions = size(examscript);
    
    x = mean_positions_array(i,1);
    y = mean_positions_array(i,2) - crop_offset;
    if x < 1
        x = 1;
    end
    if y < 1
        y = 1;
    end 
    
    examscript = imcrop(examscript,[x, y, dimensions(2) - mean_positions_array(i,1), ...
            dimensions(1) - crop_offset]);
     
   examscript = side_blackout(examscript);
    
   if exam_info{i}.flag ~= 1
       
       figure(1); imshow(examscript);
        BW = imgaussfilt(examscript, 1.5  );
        BW = edge(BW,'canny');
        [H,T,R] = hough(BW);

        imshow(H,[],'XData',T,'YData',R,...
                    'InitialMagnification','fit' );
        xlabel('\theta'), ylabel('\rho');
        axis on, axis normal, hold on;

        P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
        x = T(P(:,2)); y = R(P(:,1));
        plot(x,y,'s','color','white');

        lines = houghlines(BW,T,R,P,'FillGap',2,'MinLength',10);
        close all
        figure(2); imshow(exam_info{i}.original);
        figure, imshow(examscript), hold on
        max_len = 0;
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
           end
        end 

        plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','cyan');
        hold off
       pause
   end
    
end

function [J] = side_blackout(I)

    dimensions = size(I);
    
    if length(dimensions) > 2
        I = rgb2gray(I);
    end
    
    J = I;
    
    for col=1:dimensions(2)
        flag = 1;
        for row=1:dimensions(1)
            
            if I(row, col) > 0
                flag = 0;
                break

            end
            if row == dimensions(1) && flag == 1
                
                J = imcrop(I,[1, 1, col, dimensions(1)]);
                return
            end
        end
    end

end
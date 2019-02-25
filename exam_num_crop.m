close all

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
        
        if stats(r).Area < tot_pic_area * 0.9 && stats(r).Area > tot_pic_area * 0.005 ...
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
        fprintf('flag activated for index: %d', j);
    else    
        exam_info{j}.cropped_examnum2 = imcrop(exam_number, stats2{1}.BoundingBox);
    end
    
end

close all
%split exam number up
for i=1:length(exam_info)
    if exam_info{i}.flag == 0
    
        exam_number = exam_info{i}.cropped_examnum2;
        
        BW = imbinarize(exam_number);
        figure(1);
        imshow(BW );
        
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
    pause
    end
end
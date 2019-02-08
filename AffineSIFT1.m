close all
clc

trinity_loc = '~/mai_project_media/trinity.jpg';
trinity = imread(trinity_loc);
trinity = rgb2gray(trinity);

box_radius = 35;

for i=1:length(examscripts)
   
    
    
    examscript = rgb2gray(examscripts{i});
    
    %matches = [j i ...]
    %mean_position = [i j]
    [num, locs, mean_position, relevant_matches, matches] = match(trinity, examscript, false, 0.5);
    
    if length(matches) == 0
        [num, locs, mean_position, relevant_matches, matches] = match(trinity, examscript, false, 0.6);
    end
 
    [tform,inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform([matches(:, 3) matches(:, 4)],[matches(:, 1) matches(:, 2)],'affine');
    
    examscript = imwarp(examscript,tform);
    
    [num, locs, mean_position, relevant_matches, matches] = match(trinity, examscript, false, 0.5);
    
    if length(matches) == 0
        [num, locs, mean_position, relevant_matches, matches] = match(trinity, examscript, false, 0.6);
    end
    
    deviations = [];

    for p=1:length(matches)

        dev = sqrt((matches(p, 3) - mean_position(1))^2 + (matches(p, 4) - mean_position(2))^2);
 
        deviations = [deviations, dev];

    end
    
    %rect = smallest_bounding_rect(examscript, [matches(:, 3) matches(:, 4)]);
    
    blur = imgaussfilt(examscript,1.5);
    
    bw = imbinarize(blur);
    bw = imcomplement(bw);
    
    rect = [(mean_position(1)-box_radius) (mean_position(2)-box_radius) ...
        (2*box_radius) (2*box_radius)];
    
    bw = bwareaopen(bw, 100);
    
    %PixelID 1 = [1,1], 2 = [2, 1]
    CC = bwconncomp(bw);
    
    for k=1:length(CC.PixelIdxList)
        if length(CC.PixelIdxList{k}) > 0.3*size(examscript, 1)*size(examscript, 2)
           bw(CC.PixelIdxList{k}) = 0; 
        end
    end
    
    %CC = bwconncomp(bw);
    
    %pixlID = find_crest_CC(bw, CC, rect);
    
    stats = [regionprops(bw); regionprops(not(bw))];
    
    stats2 = {};
    inserted = 0;
    
    for r = 1:length(stats)
        rect_area = stats(r).BoundingBox(3)*stats(r).BoundingBox(4);
        if rect_area < (0.15 * size(examscript, 1) * size(examscript, 2))
            if rectint(stats(r).BoundingBox, rect) > 0
                inserted = inserted + 1;
                stats2{inserted} = stats(r);
            end
        end
    end
    
    max_area = 0;
    for r = 1:length(stats2)
        if max_area < stats2{r}.Area
            max_area = stats2{r}.Area;
            rect = stats2{r}.BoundingBox;
        end
    end
    close all
    imshow(examscript);
    hold on
    rectangle('Position', rect, 'EdgeColor', 'r');
    drawnow
    hold on
    for p=1:length(matches(:,1))
       plot(matches(p, 3),matches(p, 4 ),'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',15);
       drawnow
    end
    hold off
    
    %Remove Locations Outside of RECT
    %matches = [templateX templateY targetX targetY]
    new_matches = [];

    for m=1:length(matches(:, 1))
        point = [matches(m, 3) matches(m, 4)];
        if inRect(rect, point) == true
           new_matches = [new_matches; matches(m, :)];
        else
            fprintf('Not Inside');
        end
    end
    
    close all
    imshow(examscript);
    hold on
    rectangle('Position', rect, 'EdgeColor', 'r');
    drawnow
    hold on
    for p=1:length(new_matches(:,1))
       plot(new_matches(p, 3),new_matches(p, 4 ),'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',15);
       drawnow
    end
    hold off
    
    
    
end
    



%%Functions

function rect = smallest_bounding_rect(I, matches)
    
    %matches = [x y]
    fprintf('Comparing Connected Components...');
    [min_y, min_x] = size(I);

    rect = [1, 1, 20, 20];
    
    if length(matches) == 0
        return 
    end
    
    max_x = 1;
    max_y = 1;

    for i=1:length(matches(:, 1))
       
        if min_x > matches(i, 1)
            min_x = matches(i, 1);
        end
        if min_y > matches(i, 2)
            min_y = matches(i, 2);
        end
        if max_x < matches(i, 1)
            max_x = matches(i, 1);
        end
        if max_y < matches(i, 2)
            max_y = matches(i, 2);
        end
        
    end
    rect = [min_x min_y (max_x-min_x) (max_y-min_y)];
end

function [pixlIDlist] = find_crest_CC(I, CC, rect)
    
    [~,I] = sort(cellfun(@length,CC.PixelIdxList));
    CC.PixelIdxList = CC.PixelIdxList(I);
    

    [cols, rows] = size(I);
    box=30;
    for i=1:length(CC.PixelIdxList)
        
        pixels = CC.PixelIdxList{i};
        
        for j=1:length(pixels)
           
            x = ceil(pixels(j)/cols);
            y = rem((pixels(j)/cols), cols);
            if y == 0
                y = cols;
            end
            
            if bboxOverlapRatio(rect, [x y box box]) > 0
               pixlIDlist = i;
               return  
            end
            
        end
        
    end

end

function [bool] = inRect(rect, point)
    %[x y w h]
    x1 = rect(1);
    y1 = rect(2);
    x2 = rect(1) + rect(3);
    y2 = rect(2) + rect(4);
    bool = false;
    
    if point(1) <= x2 && point(1) >= x1
        if point(2) <= y2 && point(2) >= y1
            bool = true;
            return;
        end
    end

end

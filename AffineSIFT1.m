close all
clc

trinity_loc = '~/mai_project_media/trinity.jpg';
trinity = imread(trinity_loc);
trinity = rgb2gray(trinity);

%{
    CREST:
    [x y]
    top left = [98 79]
    top right = [280  79]
    bottom right = [280 328]
    bottom left = [98 328]
    rect = [98 79 182 249]

    EXAM NUMBER:
    top left = [496 507]
    top right = [1157 507]
    bottom right = [1157 640]
    bottom left = [496 640]
    rect = [496 507 661 133]

    GRADES FIELD:
    top left = [1763 903]
    top right = [2266  903]
    bottom right = [2266 2238]
    bottom left = [1763 2238]
    rect = [1763 903 503 1335]
%}

box_radius = 35;
exam_info = {};

for i=1:length(examscripts)
    
    fprintf('\n Analysing Image %d / %d \n\n', i, length(examscripts));
    
    s.original = examscripts{i};
    s.flag = 0;
    examscript = rgb2gray(s.original);
    
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
    
    %rect = smallest_bounding_rect(examscript, [matches(:, 3) matches(:, 4)]);
    
    blur = imgaussfilt(examscript,1.5);
    
    bw = imbinarize(blur);
    bw = imcomplement(bw);
    
    %create rect around mean for comparison
    rect = [(mean_position(1)-box_radius) (mean_position(2)-box_radius) ...
        (2*box_radius) (2*box_radius)];
    
    %remove foreground smaller than 100 pixels
    bw = bwareaopen(bw, 100);
    
    %PixelID 1 = [1,1], 2 = [2, 1]
    CC = bwconncomp(bw);
    
    for k=1:length(CC.PixelIdxList)
        if length(CC.PixelIdxList{k}) > 0.3*size(examscript, 1)*size(examscript, 2)
           bw(CC.PixelIdxList{k}) = 0; 
        end
    end
    
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
    
    %Remove Locations Outside of RECT
    %matches = [templateX templateY targetX targetY]
    boxed_matches = [];

    for m=1:length(matches(:, 1))
        point = [matches(m, 3) matches(m, 4)];
        if inRect(rect, point) == true
           boxed_matches = [boxed_matches; matches(m, :)];
        end
    end
    
    if length(boxed_matches) > 0
        rect = smallest_bounding_rect(examscript, [boxed_matches(:, 3) boxed_matches(:, 4)]);
    else 
        s.flag = 1;
    end
    examnum_rect = find_examnum_rect(rect);    
    grades_rect = find_grades_rect(rect);
    
    s.cropped_examnum = imcrop(examscript, examnum_rect);
    s.cropped_grades = imcrop(examscript, grades_rect);
    exam_info{i} = s;
end
    


%%Functions

function rect = smallest_bounding_rect(I, matches)
    
    rect = [1, 1, 20, 20];
    if length(matches) < 1
        return
    end

    %matches = [x y]
    fprintf('Comparing Connected Components...');
    [min_y, min_x] = size(I);
    
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

function [rect] = find_examnum_rect(crest_rect)
    
    %originials:
    %x1const = 2.1868;
    %y1const = 1.7189;
    %x2const = 5.8187;
    %y2const = 2.253;
    x1const = 2.2;
    y1const = 1.62;
    x2const = 6.6;
    y2const = 2.3;
    
    x = crest_rect(1) + x1const*crest_rect(3);
    y = crest_rect(2) + y1const*crest_rect(4);
    x2 = crest_rect(1) + x2const*crest_rect(3);
    y2 = crest_rect(2) + y2const*crest_rect(4);
    
    rect = [x y (x2-x) (y2-y)];

end

function [rect] = find_grades_rect(crest_rect)
    
    %originals
    %x1const = 9.1484;
    %y1const = 3.3092;
    %x2const = 11.9176;
    %y2const = 8.6706;
    
    x1const = 9.3;
    y1const = 3.9;
    x2const = 13.2;
    y2const = 8.4;
    
    x = crest_rect(1) + x1const*crest_rect(3);
    y = crest_rect(2) + y1const*crest_rect(4);
    x2 = crest_rect(1) + x2const*crest_rect(3);
    y2 = crest_rect(2) + y2const*crest_rect(4);
    
    rect = [x y (x2-x) (y2-y)];

end


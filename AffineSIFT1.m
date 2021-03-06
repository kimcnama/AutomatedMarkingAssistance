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
    try
        s.original = examscripts{i};
        s.flag = 0;
        examscript = rgb2gray(s.original);

        %matches = [j i ...]
        %mean_position = [i j]
        [num, locs, mean_position, relevant_matches, matches] = match(trinity, examscript, false, 0.5);

        if length(matches) == 0
            [num, locs, mean_position, relevant_matches, matches] = match(trinity, examscript, false, 0.6);
        end


        if length(matches(:, 1)) > 2

            %split matches
            [num_groups, num] = find_optimal_num_match_pts(matches);
            matches_cell = split_matches(matches, num_groups, num);

            affine_transforms = {};

            for a=1:length(matches_cell)
                curr_matches = matches_cell{a};
                [tform,inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform([curr_matches(:, 3) curr_matches(:, 4)],[curr_matches(:, 1) curr_matches(:, 2)],'affine');
                affine_transforms{a} = tform;
            end

            tform = median_affine(affine_transforms);

            %[tform,inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform([matches(:, 3) matches(:, 4)],[matches(:, 1) matches(:, 2)],'affine');
            examscript = imwarp(examscript,tform);
            color_examscript = imwarp(s.original,tform);

            imshow(color_examscript);

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
            if ~isempty(matches)
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
            else 
                s.flag = 1;
            end
            examnum_rect = find_examnum_rect(rect);    
            grades_rect = find_grades_rect(rect);

            s.cropped_examnum = imcrop(color_examscript, examnum_rect);
            s.cropped_grades = imcrop(color_examscript, grades_rect);
            

        end
    catch 
        fprintf('Error at index %d', i)
        s.flag = 1;
    end
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
    x1const = 2;
    y1const = 1.3;
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
    
    x1const = 8.2;
    y1const = 3.6;
    x2const = 13;
    y2const = 8.4;
    
    x = crest_rect(1) + x1const*crest_rect(3);
    y = crest_rect(2) + y1const*crest_rect(4);
    x2 = crest_rect(1) + x2const*crest_rect(3);
    y2 = crest_rect(2) + y2const*crest_rect(4);
    
    rect = [x y (x2-x) (y2-y)];

end

function [num_groups, num] = find_optimal_num_match_pts(matches)
%function figures out the optimal way to split the matches 
%before generating multiple affine transforms and RANSACING


    len = length(matches(:, 1));
    num = len;
    num_groups = 1;
    
    if len < 8
        return;
    end
    
    if rem(len, 8) == 0 
        num = 8;
        num_groups = len/num;
        return;
    end
    if rem(len, 9) == 0
        num = 9;
        num_groups = len/num;
        return;
    end
    if rem(len, 10) == 0
        num = 10;
        num_groups = len/num;
        return;
    end
    if rem(len, 11) == 0
        num = 11;
        num_groups = len/num;
        return;
    end
    if rem(len, 12) == 0
        num = 12;
        num_groups = len/num;
        return;
    end
    
    if rem(len, 8) > 5
        num = 8;
        num_groups = len/num;
        return;
    end
    if rem(len, 9) > 5
        num = 9;
        num_groups = len/num;
        return;
    end
    if rem(len, 10) > 5
        num = 10;
        num_groups = len/num;
        return;
    end
    if rem(len, 11) > 5
        num = 11;
        num_groups = len/num;
        return;
    end
    if rem(len, 12) > 5
        num = 12;
        num_groups = len/num;
        return;
    end
    
end

function [cell] = split_matches(matches, num_groups, num)
    
    insert = 1;
    cell = {};
    
    len = length(matches(:,1));
    
        %return if just one even group
        if num_groups == 1
           cell{insert} = matches;
           return
        end
        
        indices = [1:len]; %indices to sample
        
        %pick random samples
        for i=1:num_groups
            random_sample_indices = datasample(indices, num);
            
            new_matches = [];
            %create new match array remove sample indices
            for j=1:length(random_sample_indices)
                new_matches = [new_matches; matches(random_sample_indices(j), :)];
                indices = indices(indices~=random_sample_indices(j));
            end
            
            
            cell{insert} = new_matches;
            insert = insert + 1;
            
        end
        
    if length(indices) < 1
        return
    end
    
    fprintf('Length: %d \n',length(indices))
    
    if length(indices) < 5
       new_matches = cell{insert-1};
       for j=1:length(indices)
            new_matches = [new_matches; matches(indices(j), :)];
       end
        cell{insert-1} = new_matches;
        return
    end
    
    new_matches = [];
    for j=1:length(indices)
        new_matches = [new_matches; matches(indices(j), :)];
    end
    cell{insert} = new_matches;

end

function [tform] = median_affine(affine_cell)
    %function returns affine transform with smallest Euclidean distance to
    %all other transforms
    min_tot_distance = 999999999999999999999;
    tform = affine_cell{1};
        
        for i=1:length(affine_cell)
            dist = 0;
            curr_tform = affine_cell{i};
            for j=1:length(affine_cell)
                if i~=j
                    compare_tform = affine_cell{j};
                    dist = dist + norm(curr_tform.T - compare_tform.T);
                end
            end
            
            if min_tot_distance > dist
                tform = curr_tform;
                min_tot_distance = dist;
            end
        end
end



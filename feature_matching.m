%USE SIFT TO ITERATIVELY CLOSE IN ON EXAM NUMBER FIELD

%studentno_loc = '~/mai_project_media/crest_student_num_field.png';
grades_fields_loc = '~/mai_project_media/grades.png';
trinity_loc = '~/mai_project_media/trinity.jpg';
studentno_loc = '~/mai_project_media/block_capitals.png';

student_no_field = imread(studentno_loc);

trinity = imread(trinity_loc);
trinity = rgb2gray(trinity);

grades_fields = rgb2gray(imread(grades_fields_loc));

%template = rgb2gray(template);

original_crop_offsetx = 300;
original_crop_offsety = 200; 
black_out_offset = 25;
iterations = 3;

mean_positions_array = [];

for i=1:length(examscripts)
    
    fprintf('\nIteration %d / %d \n', i, length(examscripts))
    
    s = struct;
    s.flag = 0;
    
    examscript = backgroundless_scripts{i};
    
    s.original = examscript;
    
    %template always first image!!!
    [num, locs, mean_position] = match(trinity, examscript, false);
    close all
    black_out_val = mean_position(2) + black_out_offset;
    
    examscript = blackout(examscript, black_out_val);
    
    %rotation = median(locs(:, 4)) * 180/pi;
    
    %orientations = locs(:, 4) * 180/pi;
    %mask = (abs(orientations) < 90);
    %rotation2 = mean(orientations(mask));
    
    rotation2 = mean(locs(:, 4)) * 180/pi;
    %J = imrotate(examscript, rotation);
    
    %rotexamscript = imRotateCrop(examscript, rotation2);
    s.rotation = rotation2;
    examscript = imrotate(examscript, rotation2, 'bicubic', 'loose');    
    
    rotcropped_examscripts{i} = examscript;
    
    crop_offsetx = original_crop_offsetx;
    crop_offsety = original_crop_offsety;
    exam_number = rgb2gray(examscript);
     
    
    for k=1:iterations
        
        [num, locs, mean_position] = match(student_no_field, exam_number, false);
        
        close all
        if mean_position(1) == 1 && mean_position(2) == 1 && k == 1
           s.flag = 1;
            break 
        elseif mean_position(1) == 1 && mean_position(2) == 1 && k > 1
            s.exam_number = exam_number;
        end
            
        exam_number = imcrop(exam_number,[mean_position(1) - crop_offsetx, ...
            mean_position(2) - crop_offsety, 2*crop_offsetx, 2*crop_offsety]);

        if k==1
            %top of frame crop
            overall_mean_j = mean_position(2) - crop_offsety;
            overall_mean_i = mean_position(1) - crop_offsetx;
            
        elseif k==iterations
            overall_mean_j = overall_mean_j + mean_position(2) + crop_offsety;
            
        else
            overall_mean_j = mean_position(2) - crop_offsety + overall_mean_j;
            overall_mean_i = mean_position(1) - crop_offsety + overall_mean_i;
        end
        
        crop_offsetx = floor(crop_offsetx*0.9);
        crop_offsety = floor(crop_offsety*0.5);
        
       
    end
    
    mean_position = [overall_mean_i, overall_mean_j];
    mean_positions_array = [mean_positions_array; mean_position];
    
    s.exam_number = exam_number;
    exam_info{i} = s;
    
    %fprintf('median = %d ; mean = %d ; diff = %d \n', rotation, rotation2, abs(rotation - rotation2))
    fprintf('\n mean = %d \n', rotation2)    
        
    
end


%current_script = detectSURFFeatures(examscripts(1));

function [matchedPoints1, matchedPoints2, strongest1, strongest2] =  SURF(I1, I2, nStrongest, show_matches)
    
    if nargin < 3
       show_matches = false; 
    end

    points1 = detectSURFFeatures(I1);
    points2 = detectSURFFeatures(I2);
    
    [f1,vpts1] = extractFeatures(I1, points1);
    [f2,vpts2] = extractFeatures(I2, points2);
    
    indexPairs = matchFeatures(f1,f2) ;
    matchedPoints1 = vpts1(indexPairs(:,1));
    matchedPoints2 = vpts2(indexPairs(:,2));
    
    strongest1 = matchedPoints1.selectStrongest(nStrongest);
    strongest2 = matchedPoints2.selectStrongest(nStrongest);
    
    if show_matches == true
        figure; showMatchedFeatures(I1,I2,strongest1,strongest2, 'montage');
        legend('matched points 1','matched points 2');
        drawnow
    end
    
end

function [removed_scripts] = remove_non_exam_scripts(examscripts, deviation_T, show_scripts)
    
    fprintf('Inspecting extracted frames for frames NOT containing an exam script.... \n')
    
    if nargin < 2
       show_scripts = false; 
    end

    removed = cell(1);
    removed_scripts = cell(1);
    removed_count = 0;
    
    num_intensities = 256;
    
    %[avg, total, count]
    blue_channel_avg = zeros(num_intensities, 3);

    for i=1:length(examscripts)

        img = examscripts{i};

        img = rgb2hsv(img);

        B=imhist(img(:,:,1));

        for j=1:num_intensities
            blue_channel_avg(j, 3) = blue_channel_avg(j, 3) + 1;
            blue_channel_avg(j, 2) = blue_channel_avg(j, 2) + B(j, 1);
            blue_channel_avg(j, 1) = blue_channel_avg(j, 2) / blue_channel_avg(j, 3);
        end
    end

    maximum_distances = zeros(2, length(examscripts));

    for j=1:length(examscripts)
        img = examscripts{j};
        img = rgb2hsv(img);
        B = imhist(img(:,:,1));

        %{
        figure;
        plot(blue_channel_avg(:, 1), 'b')
        hold on 
        plot(B, 'r');
        hold off
        %}

        cdf_avg_runningtot = 0;
        cdf_current_runningtot = 0;

        cdf_avg = blue_channel_avg(j, 1);
        cdf_current = B;

        max_dist = -1;

        for i=1:length(blue_channel_avg(:, 1))
            cdf_avg_runningtot = cdf_avg_runningtot + blue_channel_avg(i, 1);
            cdf_current_runningtot = cdf_current_runningtot + B(i, 1);
            cdf_avg(i) = cdf_avg_runningtot;
            cdf_current(i) = cdf_current_runningtot;
            
            maximum_distances(2, j) = maximum_distances(2, j) + abs(cdf_avg_runningtot - cdf_current_runningtot);
            
            if max_dist < abs(cdf_avg_runningtot - cdf_current_runningtot)
                max_dist = abs(cdf_avg_runningtot - cdf_current_runningtot);
            end
        end

        maximum_distances(1, j) = max_dist;
        
        %{
        figure(1);
        plot(cdf_avg, 'b')
        hold on 
        plot(cdf_current, 'r');
        hold off
        pause
        %}
    end
    
    distribution = fitdist(maximum_distances(1, :).', 'Normal');
    
    for i=1:length(maximum_distances(1, :))
          
        if maximum_distances(1, i) > distribution.mu + deviation_T*distribution.sigma || ... 
            maximum_distances(1, i) < distribution.mu - deviation_T*distribution.sigma
            
            removed_count = removed_count + 1;
            removed{removed_count} = examscripts{i};
            
            if show_scripts == true
                figure;
                imshow(cell2mat(removed(removed_count)))
                
            end
            
        else
            removed_scripts{i-removed_count} = examscripts{i};
        end
        
    end   
    fprintf('%d non_exam_scripts removed \n', removed_count)
end
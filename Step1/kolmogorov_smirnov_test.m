sum_cdfs = zeros(256, 1);

color_channel = 1;
max_diffs = [];
stds_from_mu_T = 2.6;

%generate avg cdf for blue channel RGB
for i=1:length(examscripts)
   
    currFrame = rgb2hsv(examscripts{i});
    b=imhist(currFrame(:,:,color_channel));
    
    cdf = generate_cdf(b);
    
    sum_cdfs = sum_cdfs + cdf; 
    
end

avg_cdf = sum_cdfs / length(examscripts);

for i=1:length(examscripts)
   
    currFrame = rgb2hsv(examscripts{i});
    b=imhist(currFrame(:,:,color_channel));
    
    cdf = generate_cdf(b);
    
    max_diffs = [max_diffs; max(abs(cdf-avg_cdf))];
    
end

%max_diffs = (max_diffs - min(max_diffs))/(max(max_diffs)-min(max_diffs));

figure(1)
bins=14;
h=hist(max_diffs, bins)
hist(max_diffs, bins)
mu=mean(max_diffs);

squared_sum = 0;
for i=1:length(max_diffs)
    squared_sum = squared_sum + (max_diffs(i)-mu)*(max_diffs(i)-mu);
end
sigma = sqrt(squared_sum/length(max_diffs));
hold on
line([mu, mu], [0, 48])
line([mu+stds_from_mu_T*sigma, mu+stds_from_mu_T*sigma], [0, 48])
hold off

frames_removed = 0;
index_frames_to_remove = [];

for i=1:length(examscripts)
   
    currFrame = rgb2hsv(examscripts{i});
    b=imhist(currFrame(:,:,color_channel));
    
    cdf = generate_cdf(b);
    
    diff=max(abs(cdf-avg_cdf));
    
    if diff > mu+stds_from_mu_T*sigma
        figure(2); 
        ax1=subplot(2, 1, 1);
        plot(1:256, avg_cdf);
        hold on    
        plot(1:256, cdf, 'Color', 'r');
        hold off
        title('cdf')
        xlabel('b channel pixel value')
        legend(ax1,{'Average Color CDF entrie pop.','Current Color CDF'})
        
        subplot(2,1,2)
       imshow(hsv2rgb(currFrame))
       index_frames_to_remove = [index_frames_to_remove i];
       frames_removed = frames_removed + 1;
       
    end
    
end

close all
%remove scripts
for i=1:length(index_frames_to_remove)
    figure(1);
    imshow(examscripts{index_frames_to_remove(i)+1-i})
    pause
   examscripts(index_frames_to_remove(i)+1-i) = [];
   
end

function [cdf] = generate_cdf(b)
    
    cdf_running_sum = b(1);
    cdf = zeros(256, 1);
    cdf(1) = b(1);
    
    for i=2:256
        cdf_running_sum = cdf_running_sum + b(i);
         cdf(i) = cdf_running_sum;
    end

end


%{
    figure(1); 
    ax1=subplot(2, 1, 1)
    plot(1:256, avg_cdf);
    hold on    
    plot(1:256, cdf, 'Color', 'r');
    hold off
    title('cdf')
    xlabel('b channel pixel value')
    legend(ax1,{'Average Color CDF entrie pop.','Current Color CDF'})
    subplot(2, 1, 2)
    imshow(examscripts{i})
    pause
%}
close all;

frame_rate = videoObj.FrameRate;
frame_leniancy = ceil(frame_rate / 10); % 20th of a second

%odd number of frames for median filter, smooth over 1 second
if rem(frame_rate, 1) == 0
    frame_rate=frame_rate-1;
end

diff_fil = apply_median_filter(difference, frame_rate);

[pks,locs] = findpeaks(diff_fil);
total_peak_vals = 0;

for i=1:length(locs)
    max_diff = difference(locs(i));
    
    %check neighbouring frames around smoothed image for max
    for j=1:frame_leniancy
        
        if difference(locs(i)+j) > max_diff
            max_diff = difference(locs(i)+j);
            locs(i) = locs(i)+j;
        elseif difference(locs(i)-j) > max_diff
            max_diff = difference(locs(i)-j);
            locs(i) = locs(i)-j;
        end
    end
    
    total_peak_vals = total_peak_vals + max_diff;
    
end


mean_peak_val = total_peak_vals / length(locs);
T = mean_peak_val / 2;

diff_fil = apply_median_filter(difference, 7);

figure;
plot(1:length(diff_fil), diff_fil)
title('Timeline Of MSE of Frames')
xlabel('Frame')
ylabel('MSE')
hold on 
line([1, length(difference)], [mean_peak_val,mean_peak_val], 'Color','red');
line([1, length(difference)], [T,T], 'Color','red');
%for i=1:length(locs)
 %   line([locs(i), locs(i)], [1,max(difference)], 'Color','red');
%end
hold off

diff_fil = [T+1 diff_fil];

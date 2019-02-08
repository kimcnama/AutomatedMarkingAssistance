close all; 
clc; 
clear all;

%read in video file
videofile = '~/mai_project_media/scripts.mp4';
templatefile = '~/mai_project_media/cropped_template.jpg';

%approx 30 page turns
videoObj = VideoReader(videofile); 
template = imread(templatefile);

%More loop iterations than frames so discard last second of video
numFrames = int16(videoObj.FrameRate * (videoObj.Duration -1)); 
fprintf('Total Number of Frames: %d \n', numFrames);

%init difference matrix between neightbour frames
diff = zeros(1, numFrames-1); 

frame = 1;
while hasFrame(videoObj)
   currFrame = readFrame(videoObj);
   if ( frame == 1 )
     prevFrame = currFrame;
   end
   
   if frame ~= 1
    %diff(1, frame) = immse(currFrame, prevFrame);
    for color_plane = 1 : 3
        mse(color_plane) = mean( mean( (double(currFrame(:, :, color_plane)) - ...
                           double(prevFrame(:, :, color_plane))).^2 ) );
    end;
    diff(frame) = max(mse);
    
   end
   
   prevFrame = currFrame;
   frame = frame + 1;
   if ( rem(frame, 25) == 0) 
     fprintf('.%d', frame);
   end;
   if (rem(frame, 100) == 0)
     fprintf('\n');
   end;
end

medFilterDiff = apply_median_filter(diff, 5);
medFilterDiff2 = apply_median_filter(diff, 7);
diff2 = abs(diff - medFilterDiff);

bins = 60;

%plot MSE histogram
figure(1);
title('No Filter')
subplot(4,1,1)
title('Histogram Of MSE of Frames')
histogram(diff, bins)
xlabel('Mean Squared Error')
ylabel('Frequency')

subplot(4,1,2)
title('Filter N=5')
histogram(medFilterDiff, bins)
xlabel('Mean Squared Error (Median Filter=5)')
ylabel('Frequency')

subplot(4,1,3)
title('Filter N=7')
histogram(medFilterDiff2, bins)
xlabel('Mean Squared Error (Median Filter=7)')
ylabel('Frequency')

subplot(4,1,4)
title('Diff - Med(5)')
histogram(diff2, bins)
xlabel('Diff - Med(5)')
ylabel('Frequency')


%threshold = graythresh(diff);

%truncate outliers
diff = truncate_outliers(diff, bins);
medFilterDiff = truncate_outliers(medFilterDiff, bins);
medFilterDiff2 = truncate_outliers(medFilterDiff2, bins);
diff2 = truncate_outliers(diff2, bins);
bins = 50;

%plot MSE histogram without outliers 
figure(2)
subplot(4, 1, 1)
title('Histogram Of MSE of Frames (Outliers Removed)')
hist = histogram(diff, bins);
xlabel('Mean Squared Error')
ylabel('Frequency')

subplot(4, 1, 2)
title('Histogram Of MSE of Frames (Med Filter=5)')
hist1 = histogram(medFilterDiff, bins);
xlabel('Mean Squared Error (Med Filter=5)')
ylabel('Frequency')

subplot(4, 1, 3)
title('Histogram Of MSE of Frames (Med Filter=7)')
hist2 = histogram(medFilterDiff2, bins);
xlabel('Mean Squared Error (Med Filter=7)')
ylabel('Frequency')

subplot(4,1,4)
title('Diff - Med(5)')
hist3 = histogram(diff2, bins);
xlabel('Diff - Med(5)')
ylabel('Frequency')

%define threshold using gradient descent
T = grad_desc_thresh(diff, hist, bins, 0.000001, 100000, 5);
T1 = grad_desc_thresh(medFilterDiff, hist1, bins, 0.000001, 100000, 5);
T2 = grad_desc_thresh(medFilterDiff2, hist2, bins, 0.000001, 100000, 5);
T3 = grad_desc_thresh(diff2, hist3, bins, 0.000001, 100000, 5);

%timeline of MSE 
figure(3)
subplot(4,1,1)
plot(1:length(diff), diff)
title('Timeline Of MSE of Frames')
xlabel('Frame')
ylabel('MSE')
hold on
line([1, numFrames],[T,T])
hold off

subplot(4,1,2)
plot(1:length(medFilterDiff), medFilterDiff)
title('Timeline Of MSE of Frames (Median Filter=5)')
xlabel('Frame')
ylabel('MSE')
hold on
line([1, numFrames],[T1, T1])
hold off

subplot(4,1,3)
plot(1:length(medFilterDiff2), medFilterDiff2)
title('Timeline Of MSE of Frames (Median Filter=7)')
xlabel('Frame')
ylabel('MSE')
hold on
line([1, numFrames],[T2, T2])
hold off

subplot(4,1,4)
plot(1:length(diff2), diff2)
title('Timeline Of MSE - medFilter(5) of Frames')
xlabel('Frame')
ylabel('MSE')
hold on
line([1, numFrames],[T3, T3])
hold off

%grab all still shots in betwenn page turns
%compute frames of interest
candidate_frames = frames_of_interest(diff, T);
frames_diff = candidate_frames(:, 2) - candidate_frames(:, 1);

medF_candidate_frames = frames_of_interest(medFilterDiff, T1);
frames_medFilterDiff = medF_candidate_frames(:, 2) - medF_candidate_frames(:, 1);

medF_candidate_frames2 = frames_of_interest(medFilterDiff2, T2);
frames_medFilterDiff2 = medF_candidate_frames2(:, 2) - medF_candidate_frames2(:, 1);


figure(4)
subplot(3,1,1)
histogram(frames_diff, max(unique(frames_diff)))
title('Number of Neighbouring Frames Below Thresh')
xlabel('Mean Squared Error')
ylabel('Frequency')

subplot(3,1,2)
histogram(frames_medFilterDiff, max(unique(frames_medFilterDiff)))
xlabel('Mean Squared Error (Median Filter=5)')
ylabel('Frequency')

subplot(3,1,3)
histogram(frames_medFilterDiff2, max(unique(frames_medFilterDiff2)))
xlabel('Mean Squared Error (Median Filter=7)')
ylabel('Frequency')

%Extract still frames for furhter analysis
still_f = still_frames(medFilterDiff, medF_candidate_frames);

frame = 1;
n = 1;
examscripts = cell([],1);

videoObj = VideoReader(videofile); 


while hasFrame(videoObj) && n <= length(still_f)
   currFrame = readFrame(videoObj);
   
   if frame == still_f(n)
       %figure(6)
        examscripts{n} = currFrame;
        %imagesc(currFrame)
        %drawnow
        n = n + 1;
   end
   frame = frame + 1;
end

%examscripts(11) %is white paper sheet
examscripts = remove_non_exam_scripts(examscripts, 3, true);







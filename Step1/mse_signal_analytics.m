close all;

medFilterDiff = apply_median_filter(diff, 5);
medFilterDiff2 = apply_median_filter(diff, 7);
diff2 = abs(diff - medFilterDiff);

bin_width = 10;
bins = floor(max(diff) / bin_width) + 1;

%threshold = graythresh(diff);

%truncate outliers
diff = truncate_outliers(diff, bins);
medFilterDiff = truncate_outliers(medFilterDiff, bins);
medFilterDiff2 = truncate_outliers(medFilterDiff2, bins);
diff2 = truncate_outliers(diff2, bins);

%plot MSE histogram without outliers 
figure
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
T3 = floor(median(diff2));

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

medF_candidate_frames3 = frames_of_interest(diff2, T3);
frames_anils_method = medF_candidate_frames3(:, 2) - medF_candidate_frames3(:, 1);

%Extract still frames for furhter analysis
still_f = still_frames(medFilterDiff, medF_candidate_frames);

frame = 1;
n = 1;
examscripts = cell([],1);

videoObj = VideoReader(videofile); 


while hasFrame(videoObj) && n <= length(still_f)
   currFrame = readFrame(videoObj);
   
   if frame == still_f(n)
       figure(6)
        examscripts{n} = currFrame;
        imagesc(currFrame)
        drawnow
        n = n + 1;
   end
   frame = frame + 1;
end

%examscripts(11) %is white paper sheet
%examscripts = remove_non_exam_scripts(examscripts, 3, true);
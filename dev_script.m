close all; clc; clear all;

%read in video file
videofile = 'Z:/Documents/MATLAB/maiproject/media/scripts.mp4';
templatefile = 'Z:/Documents/MATLAB/maiproject/media/examtemplate.jpg';

videoObj = VideoReader(videofile); %approx 30 page turns
template = imread(templatefile);

numFrames = int16(videoObj.FrameRate * (videoObj.Duration -1)); %More loop iterations than frames so discard last second of video

diff = zeros(1, numFrames-1); %init difference matrix between neightbour frames

frame = 1;
while hasFrame(videoObj)
   currFrame = readFrame(videoObj);
   
   if frame ~= 1
    diff(1, frame) = immse(currFrame, prevFrame);
   end
   
   prevFrame = currFrame;
   frame = frame + 1;
end

bins = 60;

%plot MSE histogram
figure
title('Histogram Of MSE of Frames')
histogram(diff, bins)
xlabel('Mean Squared Error')
ylabel('Frequency')

%threshold = graythresh(diff);

%count of vals in each bin, used truncate outlier values
bin_freq = histcounts(diff, bins);

temp = find(bin_freq == 0); %matrix containing indices of where condition holds true
truncate_ind = temp(1); %truncate from first 0 val

max_mse = (max(diff) / bins) * truncate_ind; %find max MSE value, outliers are beyond this value

indices = find(diff >= max_mse);
diff(indices) = [];

%plot MSE histogram without outliers 
figure
title('Histogram Of MSE of Frames (Outliers Removed)')
histogram(diff, bins)
xlabel('Mean Squared Error')
ylabel('Frequency')

%timeline of MSE 
figure
plot(1:length(diff), diff)
title('Timeline Of MSE of Frames')
xlabel('Frame')
ylabel('MSE')
hold on
line([1, numFrames],[mean(diff), mean(diff)])
hold off

%use average for the moment but need to come up with better method for this
%part
T = mean(diff);

%grab all still shots in betwenn page turns

%compute frames of interest
page_turn = true;
candidate_frames = [];
for frame=1:length(diff)
   
    if diff(frame) < T && page_turn == true
        from = frame;
        page_turn = false;
    elseif diff(frame) >= T && page_turn == false
        to = frame;
        
        candidate_frames = vertcat(candidate_frames, [from, to]);
        
        page_turn = true;
    end
    
end

frames_diff = candidate_frames(:, 2) - candidate_frames(:, 1);

figure
title('Number of Neighbouring Frames Below Thresh')
histogram(frames_diff, bins)
xlabel('Mean Squared Error')
ylabel('Frequency')

k=2;
paramEsts= gmdistribution.fit(transpose(diff),k);

x = [min(diff):1:max(diff)];


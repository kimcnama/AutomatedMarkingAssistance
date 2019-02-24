%close all; 
clc; 
clear all;

%read in video file
videofile = '~/mai_project_media/test_script3.mp4';
%videofile = 'video_cutted.avi';
templatefile = '~/mai_project_media/cropped_template.jpg';
trinity_loc = '~/mai_project_media/trinity.jpg';
trinity = imread(trinity_loc);
trinity = rgb2gray(trinity);

%approx 30 page turns
videoObj = VideoReader(videofile); 
template = imread(templatefile);

%More loop iterations than frames so discard last second of video
numFrames = int16(videoObj.FrameRate * (videoObj.Duration -1)); 
fprintf('Total Number of Frames: %d \n', numFrames);

%sample a frame every 0.1 seconds
dist_between_frame_samples = floor((videoObj.FrameRate / 10)); 

min_match_thresh_page_turn = 15;

%init difference matrix between neightbour frames
difference = zeros(1, numFrames); 

%init difference matrix between neightbour frames
sift_matches = zeros(2, floor(numFrames/dist_between_frame_samples)+1); 

frame = 1;
array_index = 1;
while hasFrame(videoObj)
   
    currFrame = readFrame(videoObj); 
        
        if rem(frame, dist_between_frame_samples) == 0

           currFrame = rgb2gray(currFrame);

           [num, locs, mean_position, relevant_matches, matches] = match(trinity, currFrame, false, 0.5);
           close all

           sift_matches(1, array_index) = frame;
           sift_matches(2, array_index) = length(matches); 
           array_index = array_index + 1;

        end
    
   frame = frame + 1;
   %prevprevFrame = prevFrame;
   %prevFrame = currFrame;
   
   if ( rem(frame, 25) == 0) 
     clc;
     fprintf('.%d \n\n', frame);
   end
   if (rem(frame, 200) == 0)
     fprintf('\n\n');
   end
end


frames_to_extract = [];
candidate_frames = [];

for i=1:length(sift_matches(1, :))

    if sift_matches(2, i) >= min_match_thresh_page_turn
        candidate_frames = [candidate_frames sift_matches(:, i)];
    else
        if length(candidate_frames) > 0
            len = length(candidate_frames(1, :));
            max_matches = -1;
            for j=1:len
                if candidate_frames(2, len-j+1) > max_matches
                    best_frame = candidate_frames(:, len-j+1);
                    max_matches = candidate_frames(2, len-j+1);
                end
            end
            frames_to_extract = [frames_to_extract best_frame];
            candidate_frames = [];  
        end
    end
end

figure(1)
plot(sift_matches(1, :), sift_matches(2, :))
title('Timeline Of SIFT matches by frame')
xlabel('Frame')
ylabel('SIFT Matches')

videoObj = VideoReader(videofile); 
examscripts = cell([],1);

frame = 1;
inserted = 1;
while hasFrame(videoObj)
   
    currFrame = readFrame(videoObj);    
    
    if ismember(frame, frames_to_extract(1, :)) 
    
        examscripts{inserted} = currFrame;
        inserted = inserted + 1;
    end
    
    frame = frame + 1;
end

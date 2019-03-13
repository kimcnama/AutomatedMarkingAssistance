%close all; 
clc; 

trinity_loc = '~/mai_project_media/trinity.jpg';
trinity = imread(trinity_loc);
trinity = rgb2gray(trinity);

%approx 30 page turns
videoObj = VideoReader(videofile); 
template = imread(templatefile);

%More loop iterations than frames so discard last second of video
numFrames = int16(videoObj.FrameRate * (videoObj.Duration -1)); 
fprintf('Total Number of Frames: %d \n', numFrames);

min_match_thresh_page_turn = 15;

sift_frame_skip = round(videoObj.FrameRate / 10); % sample frame every 10th of a sec

frame = 1;
frames_to_extract = [];
max_matches = -1;
index = -1;
drop_below_thresh_count = 0;

while hasFrame(videoObj)
   
    currFrame = readFrame(videoObj); 
        
        if diff_fil(frame) < T 
            try
                if rem(drop_below_thresh_count, sift_frame_skip) == 0
                   currFrame = rgb2gray(currFrame);

                   [num, locs, mean_position, relevant_matches, matches] = match(trinity, currFrame, false, 0.5);
                   close all

                   if length(matches) >= max_matches && length(matches) >= min_match_thresh_page_turn

                       max_matches = length(matches);
                       index = frame;

                   end
            
                end
            catch
                fprintf('\n Error on frame %d \n', frame);
            end
            page_turned = false;
            drop_below_thresh_count=drop_below_thresh_count+1;
        else 
            if index > -1 
                frames_to_extract = [frames_to_extract index];
            end
            max_matches = -1;
            index = -1;
            drop_below_thresh_count = 0;
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

videoObj = VideoReader(videofile); 
examscripts = {};
inserted = 1;
frame=1;
while hasFrame(videoObj)
   currFrame = readFrame(videoObj);
    if ismember(frame, frames_to_extract)
        disp('inserting frame')
        examscripts{inserted} = currFrame;
        inserted = inserted + 1;
    end
    frame = frame + 1;
    if frame > frames_to_extract(length(frames_to_extract))
        break;
    end
end


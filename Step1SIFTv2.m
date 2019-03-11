%close all; 
clc; 

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

min_match_thresh_page_turn = 15;

frame = 1;
examscripts = cell([],1);
frames_to_extract = [];

while hasFrame(videoObj)
   
    currFrame = readFrame(videoObj); 
        
        if diff_fil(frame) < T

           currFrame = rgb2gray(currFrame);

           [num, locs, mean_position, relevant_matches, matches] = match(trinity, currFrame, false, 0.5);
           close all
            
           if length(matches) >= max_matches && length(matches) >= min_match_thresh_page_turn
           
               max_matches = length(matches);
               index = frame;
               
           end
                      
           array_index = array_index + 1;
           page_turned = false;
        else 
            frames_to_extract = [frames_to_extract index];
            max_matches = -1;
            index = -1;
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



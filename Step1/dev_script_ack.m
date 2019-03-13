%close all; 
clc; 
clear all;

%read in video file
videofile = '~/mai_project_media/test_script2.mp4';
%videofile = 'video_cutted.avi';
templatefile = '~/mai_project_media/cropped_template.jpg';

%approx 30 page turns
videoObj = VideoReader(videofile); 
template = imread(templatefile);

%More loop iterations than frames so discard last second of video
numFrames = int16(videoObj.FrameRate * (videoObj.Duration -1)); 
fprintf('Total Number of Frames: %d \n', numFrames);

%init difference matrix between neightbour frames
difference = zeros(1, numFrames); 

num_frames_backtrack = floor((videoObj.FrameRate / 5)) - 1; %0.2 seconds

prev_frames = cell(num_frames_backtrack, 1);

frame = 1;
while hasFrame(videoObj)
   
   currFrame = readFrame(videoObj); 
    
   if frame > num_frames_backtrack && frame > 1
        
        mse_frames = zeros(num_frames_backtrack, 1);
        
        frame1 = currFrame;
        
        for backtrack=1:num_frames_backtrack
            
            frame2 = prev_frames{num_frames_backtrack - backtrack + 1};
            
            for color_plane = 1 : 3
                mse(color_plane) = mean( mean( (double(frame1(:, :, color_plane)) - ...
                                   double(frame2(:, :, color_plane))).^2 ));
            end     

        mse_frames(backtrack) = max(mse);
        frame1 = frame2;
        
        end
        
        difference(frame) = sum(mse_frames);
   end
   
   for j=1:length(prev_frames)-1
      prev_frames{j} = prev_frames{j+1}; 
   end
   
   prev_frames{length(prev_frames)} = currFrame;
   
   frame = frame + 1;
   
   if ( rem(frame, 25) == 0) 
     fprintf('.%d', frame);
   end
   if (rem(frame, 200) == 0)
     fprintf('\n');
   end
end









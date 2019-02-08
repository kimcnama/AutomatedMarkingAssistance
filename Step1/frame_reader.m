%read in video file
videoObj = VideoReader('../media/scripts.mp4'); %approx 30 page turns
template = imread('../media/examtemplate.jpg');

frame_capture = false;
still_frame_counter = 0;
still_frames_cap_threshold = 2;

counter = 0;

numFrames = int16(videoObj.FrameRate * (videoObj.Duration -1)); %More loop iterations than frames so discard last second of video

for frame=1:numFrames
    counter = counter + 1;
   currFrame = readFrame(videoObj);
   MSE = immse(currFrame, prevFrame);
   disp(MSE)
   if MSE =< 0.2 && frame_capture == false
       still_frame_counter = still_frame_counter + 1;
       if still_frame_counter >= still_frames_cap_threshold
          disp('Should Show Image')
          still_frame_counter = 0;
          frame_capture = true;
          analysis_images = [analysis_images currFrame];
          figure 
          imshow(currFrame);
          drawnow;
       end
   elseif frame_capture == true && MSE > 0
       frame_capture = false;
   end
end
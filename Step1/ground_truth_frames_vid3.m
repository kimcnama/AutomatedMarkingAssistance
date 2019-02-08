close all; 
clc; 
clear all;

true_frames = [11,83,157,218,280,363,445,540,628,700,864,921,986,1048,1130,1210,1292,1352,1440,1515,1574,1670,1748,1830,1900,2020];

videofile = '~/mai_project_media/test_script3.mp4';
videoObj = VideoReader(videofile); 

examscripts = cell([],1);

frame = 1;
n=1;
while hasFrame(videoObj)
   currFrame = readFrame(videoObj);
   
   for j=1:length(true_frames)
      if frame == true_frames(j)
          figure(6)
        examscripts{n} = currFrame;
        imagesc(currFrame)
        drawnow
        n=n+1;
      end
   end
   
   frame = frame + 1;
   
   if ( rem(frame, 25) == 0) 
     fprintf('.%d', frame);
   end
   if (rem(frame, 200) == 0)
     fprintf('\n');
   end
end
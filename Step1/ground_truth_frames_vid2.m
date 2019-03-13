close all; 
clc; 
clear all;

true_frames = [70,500,610,770,880,970,1065,1340,1470,1640,1770,1880,2000,2500,2670,2845,2960,3080,3200,3300,3500,3620,3860,3980,4130,4250,4385,4500,4720,4880,4940,5160,5285,5520,5580,5680,5760,5850,6030,6120,6260,6390,6500,6610,6720,6860,6980,7170,7470,7560,7700,7780,7900,8025,8150,8280,8420,8510,8700,8800,9120,9210,9310,9410,9510,9640,9830,10140,10180,10400,10510,10610,10670,10740,10950,11080,11210,11450,11600,11730,11870,12000,12150,12300];

videofile = '~/mai_project_media/test_script2.mp4';
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
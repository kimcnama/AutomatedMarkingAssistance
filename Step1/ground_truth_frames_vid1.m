close all; 
clc; 
clear all;

true_frames = [33,150,284,390,476,560,640,876,1090,1170,1270,1360,1580,1690,1720,2065,2160,2250,2380,2480,2600,2710,2820,2920,3170,3270,3400,3500,3630,3710,3860,3970,4070,4250,4490,4600,4720,4880,4980,5070,5140,5240,5370,5460,5630,5760,6090,6200,6300,6380,6520,6710,6840,6950,7080,7200,7310,7400,7510,7660,7790,8020,8140,8240,8350,8470,8630,8760,8910,9010,9170,9320,9840,10140,10240,10400,10530,10670,10760,10970,11110,11230,11430,11560,11680,11780,11950,12050,12160,12270,12400,12530,12640,12750,12870];

videofile = '~/mai_project_media/test_script1.mp4';
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
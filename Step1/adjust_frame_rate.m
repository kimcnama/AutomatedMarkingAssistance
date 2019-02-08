nFrames = floor(videoObj.Duration * videoObj.FrameRate);

output = 'video_cutted';

writerObj = VideoWriter(output);
writerObj.FrameRate = 15; 

open(writerObj);

skipN = 1:2:nFrames;
vidHeight = videoObj.Height;
vidWidth = videoObj.Width;

mov(1:nFrames - numel(skipN)) = struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),'colormap', []);
for i =  1:nFrames
  j = find(i== skipN);
  if any(j)
      continue
  end
  mov(i).cdata = read(videoObj, i);
  writeVideo(writerObj, mov(i).cdata);
end
close (writerObj);
clear writerObj
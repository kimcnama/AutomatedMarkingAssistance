examscripts = {};
inserted = 1;
frame=1;
while hasFrame(videoObj)
   
    if ismember(frame, frames_to_extract)
        disp('inserting frame')
        currFrame = readFrame(videoObj);
        examscripts{inserted} = currFrame;
        inserted = inserted + 1;
    end
    frame = frame + 1;
end
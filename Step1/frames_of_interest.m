function [candidate_frames] = frames_of_interest(series, T) 

%compute frames of interest
page_turn = true; %page currently turning
candidate_frames = [];
for frame=1:length(series)
    if series(frame) < T && page_turn == true
        from = frame;
        page_turn = false;
    elseif series(frame) >= T && page_turn == false
        to = frame;
        
        candidate_frames = vertcat(candidate_frames, [from, to]);
        
        page_turn = true;
    end
    
end
end
min_match_thresh_page_turn = 5;

frames_to_extract = [];
candidate_frames = [];

for i=1:length(sift_matches(1, :))

    if sift_matches(2, i) >= min_match_thresh_page_turn
        candidate_frames = [candidate_frames sift_matches(:, i)];
    else
        if length(candidate_frames) > 0
            len = length(candidate_frames(1, :));
            max_matches = -1;
            for j=1:len
                if candidate_frames(2, len-j+1) > max_matches
                    best_frame = candidate_frames(:, len-j+1);
                    max_matches = candidate_frames(2, len-j+1);
                end
            end
            frames_to_extract = [frames_to_extract best_frame];
            candidate_frames = [];  
        end
    end
end
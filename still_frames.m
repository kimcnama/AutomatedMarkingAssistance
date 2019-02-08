function [still_frames] = still_frames(diff_series, candidate_frames)

still_frames = zeros([1, length(candidate_frames)]);


for i=1:length(candidate_frames)
   curr_wind = [candidate_frames(i), candidate_frames(i, 2)];
   min = diff_series(curr_wind(1));
   min_frame = curr_wind(1);
   for j=curr_wind(1):curr_wind(2)
        if diff_series(j) <= min 
            min = diff_series(j);
            min_frame = j;
        end
   end
   still_frames(i) = j;
end

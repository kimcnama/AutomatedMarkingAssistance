function [med_series] = apply_median_filter(series, window_size)

if rem(window_size, 2) == 0
    error('Need odd window size number')
end

med_series = series;

for i=1:length(med_series)
   med_series(i) = median_filter(series, i, window_size);
end
function [trimmed_series] = truncate_outliers(series, bins)

%count of vals in each bin, used truncate outlier values
bin_freq = histcounts(series, bins);

temp = find(bin_freq == 0); %matrix containing indices of where condition holds true
truncate_ind = temp(1); %truncate from first 0 val

max_mse = (max(series) / bins) * truncate_ind; %find max MSE value, outliers are beyond this value

indices = find(series >= max_mse); %vector of indices where condition holds true (want to remove these outliers)
trimmed_series = series;
trimmed_series(indices) = [];


%ORIGINAL CODE SNIPPET
%{
%count of vals in each bin, used truncate outlier values
bin_freq = histcounts(medFilterDiff2, bins);

temp = find(bin_freq == 0); %matrix containing indices of where condition holds true
truncate_ind = temp(1); %truncate from first 0 val

max_mse = (max(medFilterDiff2) / bins) * truncate_ind; %find max MSE value, outliers are beyond this value

indices = find(medFilterDiff2 >= max_mse);
medFilterDiff2(indices) = [];
%}
function [med] = median_filter(x, index, window_size)

%odd 

len = length(x);

if index < 0 || index > len
    error('Index out of range')
end 
if rem(window_size, 2) == 0
    error('Need odd window size number')
end

out_of_bounds_val = 0;
steps = floor(window_size / 2);
window = zeros(1, window_size);
window(1) = x(index);

insert_ind = 2;
for i=1:steps
    if index + i > len
        window(insert_ind) = out_of_bounds_val;
    else
        window(insert_ind) = x(index + i);
    end
    insert_ind = insert_ind + 1;
    
    if index - i < 1
        window(insert_ind) = out_of_bounds_val;
    else
        window(insert_ind) = x(index - i);
    end
    insert_ind = insert_ind + 1;
end

window = sort(window);
med = median(window);

end
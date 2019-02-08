new_matches = [];

for i=1:length(matches(:, 1))
    point = [matches(i, 3) matches(i, 4)];
    if inRect(rect, point) == true
       new_matches = [new_matches; matches(i, :)];
    else
        fprintf('Not Inside');
    end
end

function [bool] = inRect(rect, point)
    %[x y w h]
    x1 = rect(1);
    y1 = rect(2);
    x2 = rect(1) + rect(3);
    y2 = rect(2) + rect(4);
    bool = false;
    
    if point(1) <= x2 && point(1) >= x1
        if point(2) <= y2 && point(2) >= y1
            bool = true;
            return;
        end
    end

end
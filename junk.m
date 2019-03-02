rectA_contained_in_rectB(stats2{4}.BoundingBox, stats2{3}.BoundingBox)

function [bool] = rectA_contained_in_rectB(rectA, rectB)
    bool = false;
    
    %check x's
    if rectA(1) > rectB(1) && (rectA(1)+rectA(3)) < (rectB(1)+rectB(3))
        if rectA(2) > rectB(2) && (rectA(2)+rectA(4)) < (rectB(2)+rectB(4))
            bool = true;
        end
    end
end
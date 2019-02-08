function [J] = blackout(I, blackoutval)
    
    if blackoutval == 0
        blackoutval = 1;
    end

    image_size = size(I);
    
    for j=1:blackoutval
        for k=1:image_size(2)
           I(j, k, 1) = 0;
           I(j, k, 2) = 0;
           I(j, k, 3) = 0;
        end
    end
    J = I;
end
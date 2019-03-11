
figure(1); imshow(num);

num1 = trim_outside_of_image(num, 0.4);
figure(2); imshow(num1);

num2 = cut_image_to_ar_ratio1(num1, 0.05);
figure(3); imshow(num2);

function [J] = cut_image_to_ar_ratio1(I, T)

    %T is a percentage, so if 0.1, ar must fall between +- 10%

    J=I;
    [cols, rows] = size(J);
    
    cuts_right = 0;
    cuts_left = 0;
    
    ar = rows/cols;
    
    %alternate between sides
    prev_side = 1;
    leniancy = 2;
    
    while ar >= (1 + T) 
        
        [cols, rows] = size(J);
        
        prev_side = 0; %right side
        
        obj_pixels1 = 0;
        
        for i=1:cols 
            obj_pixels1 = obj_pixels1 + J(i, 1); %left side
        end 
        
        obj_pixels2 = 0;
        for i=1:cols 
            obj_pixels2 = obj_pixels2 + J(i, rows); %right side
        end 
        
        
        
        if obj_pixels1 == obj_pixels2
            if prev_side == 1
                J = J(:, 1:rows-1);
                prev_side = 0;
            else 
                J = J(:, 2:rows);
                prev_side = 1;
            end
        elseif obj_pixels1 < obj_pixels2 + leniancy
            %cut left
            J = J(:, 2:rows);
            prev_side = 1;
            cuts_left = cuts_left + 1;
            
        else 
            %cut right
            J = J(:, 1:rows-1);
            prev_side = 0;
            cuts_right = cuts_right + 1;
            
        end
        
        leniancy = -leniancy;
        
        [cols, rows] = size(J);
        ar = rows/cols;
    end
   
end

function [J] = trim_outside_of_image(I, T)
    J=I;
    
    %top edge
    remove_edge = true;
    while remove_edge == true
        obj_pixels = 0;
        [cols, rows] = size(J);
        for i=1:rows
            obj_pixels = obj_pixels + J(1, i);
        end
        if obj_pixels >= rows*T
            J = J(2:cols, :);
        else
            remove_edge = false;
        end
    end
    
    %bottom edge
    remove_edge = true;
    while remove_edge == true
        obj_pixels = 0;
        [cols, rows] = size(J);
        for i=1:rows
            obj_pixels = obj_pixels + J(cols, i);
        end
        if obj_pixels >= rows*T
            J = J(1:cols-1, :);
        else
            remove_edge = false;
        end
    end
    
    %left edge
    remove_edge = true;
    while remove_edge == true
        obj_pixels = 0;
        [cols, rows] = size(J);
        for i=1:cols 
            obj_pixels = obj_pixels + J(i, 1);
        end
        if obj_pixels >= cols*T
            J = J(:, 2:rows);
        else
            remove_edge = false;
        end
    end
    
    %right edge
    remove_edge = true;
    while remove_edge == true
        obj_pixels = 0;
        [cols, rows] = size(J);
        for i=1:cols 
            obj_pixels = obj_pixels + J(i, rows);
        end
        if obj_pixels >= cols*T
            J = J(:, 1:rows-1);
        else
            remove_edge = false;
        end
    end
    
end
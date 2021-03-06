I = [1:8; 1:8; 1:8;1:8;1:8;1:8;1:8;1:8];
J = insert_padding(I, 2)

figure(1)
imshow(I);
figure(2)
imshow(J);


function [J] = insert_padding(I, n)

    %do top and bottom edge first
    J=I;
    [cols, rows] = size(J);
    
    A = zeros(1, rows);
    
    for i=1:n
        J = [A;J];
        J = [J;A];
    end
    
    [cols, rows] = size(J);
    A = zeros(cols, 1);
    
    for i=1:n
        J = [A J];
        J = [J A];
    end
end
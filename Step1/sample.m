
% read in image
I = double(rgb2gray(imread('sample.png')));
[Jrows,Jcols] = size(I);



f = im2double(imread('W:\5C1\Lab1\Heather_HD.tif'));
Y = 0.3*f(:,:,1)+0.6*f(:,:,2)+0.1*f(:,:,3);
U = -0.15*f(:,:,1)-0.3*f(:,:,2)+0.45*f(:,:,3);
V = 0.4375*f(:,:,1)-0.375*f(:,:,2)-0.0625*f(:,:,3);

b = im2double(imread('W:\5C1\Lab1\Tobago_HD.tif'));
w = im2double(imread('segment.tif')); %rgb2ntsc

Yw = 0.3*w(:,:,1)+0.6*w(:,:,2)+0.1*w(:,:,3);
Uw = -0.15*w(:,:,1)-0.3*w(:,:,2)+0.45*w(:,:,3);
Vw = 0.4375*w(:,:,1)-0.375*w(:,:,2)-0.0625*w(:,:,3);

meanYw  = mean2(Yw);  devYw = std2(Yw);
meanUw  = mean2(Uw);  devUw = std2(Uw);
meanVw  = mean2(Vw);  devVw = std2(Vw);

Et = 100;
E = (((Y-meanYw).^2)/(2*(devYw.^2))    +   ((U-meanUw).^2)/(2*(devUw.^2))   +   ((V-meanVw).^2)/(2*(devVw.^2)) );
figure, imshow(E,[]);
alpha = zeros(size(E)); alpha(E>Et)=1; 
figure, imshow(alpha)

out = f.*alpha + b.*(1-alpha);
figure, imshow(out);




% Compute edge map of image
[Gmag,Gdir] = imgradient(I);
% figure, imshow(uint8(Gmag),[]);
% Divide image and edge image into 8x8 pixel sub images of non-overlapping blocks
block_size = 20;
num_sub_rows = Jrows/block_size; num_sub_cols = Jcols/block_size;
m_vec = block_size*ones(1,num_sub_rows); n_vec = block_size*ones(1,num_sub_cols);
J = mat2cell(I,m_vec,n_vec);    %figure,imshow(J{1,1});

% ******************* Compute modified entropy for each sub-block ********************
    Ep = zeros(num_sub_rows*num_sub_cols,3);
    pos = 1;
    for m=1:num_sub_rows
        for n = 1:num_sub_cols
            
            % Compute edge entropy for each sub-block from edge image
            p = imhist(uint8(J{m,n})); % create pdf for pixels in each sub block
            p(p==0) = [];       % isolate non-zero pixels
            p = p ./(block_size*block_size);      % normalize pdf
            entropy_edge = -sum(p.*log2(p)); % edge entropy 
 
            % Compute gray level entropy for each sub-block from original image
            p = imhist(uint8(J_jpeg{m,n})); % create pdf for pixels in each sub block
            p(p==0) = [];       % isolate non-zero pixels
            p = p ./(block_size*block_size);      % normalize pdf
            entropy_gray = sum(p.*exp(1-p)); % grayscale entropy  
            
            Ep(pos,3) = entropy_gray + entropy_edge;
            Ep(pos,1) = m;      % save row location
            Ep(pos,2) = n;      % save col location
            pos = pos + 1;
        end
    end    
    %sort list in ascending order of Entropy values
    Ep = sortrows(Ep,3);
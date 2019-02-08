close all;

diff_fil5 = apply_median_filter(difference, 5);
diff_fil7 = apply_median_filter(difference, 7);
sub_diff = abs(difference - diff_fil5);

%timeline of MSE 
figure
subplot(4,1,1)
plot(1:length(difference), difference)
title('Timeline Of MSE of Frames')
xlabel('Frame')
ylabel('MSE')

subplot(4,1,2)
plot(1:length(diff_fil5), diff_fil5)
title('Timeline Of MSE of Frames (Median Filter=5)')
xlabel('Frame')
ylabel('MSE')

subplot(4,1,3)
plot(1:length(diff_fil7), diff_fil7)
title('Timeline Of MSE of Frames (Median Filter=7)')
xlabel('Frame')
ylabel('MSE')

subplot(4,1,4)
plot(1:length(sub_diff), sub_diff)
title('Timeline Of MSE - medFilter(5) of Frames')
xlabel('Frame')
ylabel('MSE')

figure;

subplot(4,1,1)
plot(1:length(diff_fil7), diff_fil7)
title('Timeline Of MSE of Frames (Median Filter=7)')
xlabel('Frame')
ylabel('MSE')
hold on 
line([1, length(diff_fil7)], [mean(diff_fil7), mean(diff_fil7)]);
hold off

subplot(4,1,2)
dy=diff(diff_fil7)./diff(1:length(diff_fil7));
plot(1:length(diff_fil7)-1,dy);
title('dy/dx')
xlabel('Frame')
ylabel('MSE')

%dyy < 0  - local max
%dyy > 0  - local min
subplot(4,1,3)
dyy=diff(dy)./diff(1:length(dy));
plot(1:length(dyy),dyy);
title('dyy/dxx')
xlabel('Frame')
ylabel('MSE')


dyy = [0, 0, dyy];
dyy_scaled = dyy;
for i=1:length(dyy)
    
    dyy_scaled(i)=(dyy(i)*diff_fil7(i)*diff_fil7(i))/max(diff_fil7);
    
end

subplot(4,1,4)
plot(1:length(dyy_scaled),dyy_scaled);
title('dyy/dxx scaled')
xlabel('Frame')
ylabel('MSE')


threshold = mean(diff_fil7);

diff_fil7_topped = diff_fil7;
for i=1:length(diff_fil7)
   
    if diff_fil7_topped(i) > threshold
        diff_fil7_topped(i) = threshold;
    end
    
end

figure
plot(1:length(diff_fil7_topped), diff_fil7_topped);


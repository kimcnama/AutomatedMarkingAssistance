function [T] = grad_desc_thresh(series, hist, bins, precision, max_iters, order)

bin_len = max(series)/bins;
mse_curveX = (bin_len/2:bin_len:max(series));

p = polyfit(mse_curveX, hist.Values, order);
v = polyval(p, mse_curveX);

%to initialize 
learning_rate = 0.01;
cur_x = 0;
prev_step_size = 1;
iters = 0;
%max_iters = 100000;
%precision = 0.000001;

deltap = differenciate(p);
while prev_step_size > precision && iters < max_iters
   prev_x = cur_x;
   cur_x = cur_x - learning_rate * polyval(deltap, prev_x);
   prev_step_size = abs(cur_x - prev_x);
   iters = iters + 1;
   %{
   if rem(iters, 1500) == 0
       fprintf('Gradient Descent Iteration %d ', iters);
       fprintf(' X= %d \n', cur_x);
   end
   %}
end
T = floor(cur_x);

figure
histogram(series, 50)
hold on
plot(mse_curveX, hist.Values)
plot(mse_curveX, v, 'MarkerEdgeColor', 'Red')
plot([T,T],[0,200])
hold off

end



   
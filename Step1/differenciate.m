function [deltap] = differenciate(p)

if length(p) < 2
    error('order polynomial too small')
end 

deltap = p;
deltap(length(deltap)) = [];
order = length(deltap);

for i=0:order
    if order - i > 0
    deltap(i+1) = deltap(i+1) * (order-i);
    end
end
end
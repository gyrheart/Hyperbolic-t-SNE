function Y = fRescale(X,A)
y1 = A(1);
y2 = A(2);
x1 = min(X);
x2 = max(X);
if x2-x1 ~= 0
Y  = y1+(y2-y1)/(x2-x1)*(X-x1);
else
    Y = zeros(size(X));
end

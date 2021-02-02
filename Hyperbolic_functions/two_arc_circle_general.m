function [S] = two_arc_circle_general(x1,y1,r1,x2,y2,r2,q)
%find intersection of the two circles (the mother point of them)
[sx,sy] = intersection_two_circles(x1,y1,r1,x2,y2,r2);
syms a b c d x y
syms r 
S = vpasolve([y == -(c-a)/(d-b)*(x-(a+c)/2)+(b+d)/2, x^2+y^2==1+r^2, ...
        (a-x1)^2+(b-y1)^2==r1^2, (c-x2)^2+(d-y2)^2==r2^2, ...
        (x-a)^2+(y-b)^2==r^2, x^2+y^2==a^2+b^2+r^2-2*sqrt(a^2+b^2)*r*cos(2*pi/q+pi-atan(abs(b/a))-atan(abs((y1-b)/(x1-a)))),...
        x^2+y^2==c^2+d^2+r^2-2*sqrt(c^2+d^2)*r*cos(2*pi/q+pi-atan(abs(d/c))-atan(abs((y2-d)/(x2-c))))],[a, b, c, d, x, y, r],zeros(1,7));
%[sx, sy, sx, sy, sx+0.1, sy, 0.1]
end


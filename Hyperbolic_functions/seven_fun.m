function [F] = seven_fun(input,x1,y1,r1,x2,y2,r2,q)
%input = [a b c d x y r]
a = input(1);
b = input(2);
c = input(3);
d = input(4);
x = input(5);
y = input(6);
r = input(7);
F(1) = -y-(c-a)/(d-b)*(x-(a+c)/2)+(b+d)/2;
F(2) = x^2+y^2==1+r^2;
F(3) = (a-x1)^2+(b-y1)^2-r1^2;
F(4) = (c-x2)^2+(d-y2)^2-r2^2;
F(5) = (x-a)^2+(y-b)^2-r^2;
F(6) = -x^2-y^2+a^2+b^2+r^2-2*sqrt(a^2+b^2)*r*cos(2*pi/q+pi-atan(abs(b/a))-atan(abs((y1-b)/(x1-a))));
F(7) = -x^2-y^2+c^2+d^2+r^2-2*sqrt(c^2+d^2)*r*cos(2*pi/q+pi-atan(abs(d/c))-atan(abs((y2-d)/(x2-c))));
end


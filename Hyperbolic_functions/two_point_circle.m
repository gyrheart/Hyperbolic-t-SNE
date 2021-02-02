function [x,y,r] = two_point_circle(x1,y1,x2,y2)
%Given two points, this code returns the circle center and radius that pass
%through the two points.
x = (x1^2+y1^2+1-2*y1*(x2-x1)/(y2-y1)*(x1+x2)/2-2*y1*(y1+y2)/2)/(2*x1-2*y1*(x2-x1)/(y2-y1));
y = -(x2-x1)/(y2-y1)*(x-(x1+x2)/2)+(y1+y2)/2;
r = sqrt(x^2+y^2-1);
end


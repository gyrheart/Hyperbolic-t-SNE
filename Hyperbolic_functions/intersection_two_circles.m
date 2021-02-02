function [sx,sy] = intersection_two_circles(x1,y1,r1,x2,y2,r2)
%This code finds the intersection point given the centers and radii of two
%circles
theta = acos(((x1-x2)^2+(y1-y2)^2+r2^2-r1^2)/2/r2/sqrt((x1-x2)^2+(y1-y2)^2));
[alpha,~] = cart2pol(x1-x2,y1-y2);
%two possible intersections, choose the one within the unit circle
sx = r2*cos(alpha+theta)+x2;
sy = r2*sin(alpha+theta)+y2;
if sx^2+sy^2>=1
    sx = r2*cos(alpha-theta)+x2;
    sy = r2*sin(alpha-theta)+y2;
end

end
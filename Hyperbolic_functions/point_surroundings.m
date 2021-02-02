function [xyr,theta] = point_surroundings(x_p,y_p,x1,y1,q)
%This code finds the centers and radii of circles given a point and an arc
%(specified using center and radius of the circle) passing through the
%point (the mother arc to that point whenever possible), to give equal
%angles at a vertex.

xyr = [];
rho_all = linspace(0,2*pi,500);
%angle between origin-point line and arc through the point
theta = acos((x_p^2+y_p^2+(x1-x_p)^2+(y1-y_p)^2-x1^2-y1^2)/2/sqrt(x_p^2+y_p^2)/sqrt((x1-x_p)^2+(y1-y_p)^2))-pi/2;
if (y_p/x_p)<(y1/x1)
    theta = -theta;
end

for j = 1:q-1
    angle_j = theta+2*pi/q*j;  %angle from the origin-point line
    if abs(angle_j) >= 0.001
        r = abs((x_p^2+y_p^2-1)/(2*sqrt(x_p^2+y_p^2)*cos(pi/2+2*pi/q*j+theta)));
        a = 1+y_p^2/x_p^2;
        b = -y_p*(x_p^2+y_p^2+1)/x_p^2;
        c = (x_p^2+y_p^2+1)^2/4/x_p^2-r^2-1;
        y = (-b-sqrt(b^2-4*a*c))/2/a;  %y_coor of center of outside circle
        x = (x_p^2+y_p^2+1-2*y_p*y)/2/x_p;  %x_coor of center of outside circle
        %y_coor has two possible solutions
        [temp,~] = cart2pol(x-x_p,y-y_p);
        %if abs(temp+pi-pi/2-angle_j)>=0.001 && abs(temp+pi+pi/2-angle_j)>=0.001    %only works for the first layer, try this first when debugging
        %angle_temp = acos((x_p^2+y_p^2+(x-x_p)^2+(y-y_p)^2-x^2-y^2)/2/sqrt(x_p^2+y_p^2)/sqrt((x-x_p)^2+(y-y_p)^2));
        %if abs(angle_temp-pi/2-angle_j)>=0.001 && abs(angle_temp+pi/2-angle_j)>=0.001 && abs(2*pi-angle_temp-pi/2-angle_j)>=0.001 && abs(2*pi-angle_temp+pi/2-angle_j)>=0.001
        [temp2,~] = cart2pol(x_p,y_p);
        if abs(temp-temp2+pi-pi/2-angle_j)>=0.001 && abs(temp-temp2+pi+pi/2-angle_j)>=0.001
            y = (-b+sqrt(b^2-4*a*c))/2/a;
            x = (x_p^2+y_p^2+1-2*y_p*y)/2/x_p;
        end
        
%         %plot the circle and check if any point sits at the right angle from the origin-point line
%         x_c = r*cos(rho_all)+x;
%         y_c = r*sin(rho_all)+y;
%         z_c = x_c.^2+y_c.^2;
%         x_c = x_c(z_c<=1);
%         y_c = y_c(z_c<=1);
%         %choose the closest points to the given point
%         d = (x_c-x_p).^2+(y_c-y_p).^2;
%         [~,ind] = sort(d);
%         x_c = x_c(ind(1:5));
%         y_c = y_c(ind(1:5));
%         count = 0;
%         for i = 1:length(x_c)
%             test_angle = acos((x_p^2+y_p^2+(x_c(i)-x_p)^2+(y_c(i)-y_p)^2-x_c(i)^2-y_c(i)^2)/2*sqrt(x_p^2+y_p^2)*sqrt((x_c(i)-x_p)^2+(y_c(i)-y_p)^2));
%             if angle_j <= pi
%                 if abs(test_angle-angle_j)<=0.02
%                     count = count+1;
%                 end
%             else
%                 if abs(2*pi-test_angle-angle_j)<=0.02
%                     count = count+1;
%                 end
%             end
%         end
%         if count == 0  %r is computed wrong, no correct angle is found
%             r = (x_p^2+y_p^2-1)/(2*sqrt(x_p^2+y_p^2)*cos(-pi/2+2*pi/q*j+theta));
%             a = 1+y_p^2/x_p^2;
%             b = -y_p*(x_p^2+y_p^2+1)/x_p^2;
%             c = (x_p^2+y_p^2+1)^2/4/x_p^2-r^2-1;
%             y = (-b-sqrt(b^2-4*a*c))/2/a;  %y_coor of center of outside circle
%             x = (x_p^2+y_p^2+1-2*y_p*y)/2/x_p;  %x_coor of center of outside circle
%             %y_coor has two possible solutions
%             [temp,~] = cart2pol(x-x_p,y-y_p);
%             if abs(temp+pi/2 - 2*pi/q*j)>=0.001 && abs(pi+temp+pi/2 - 2*pi/q*j)>=0.001
%                 y = (-b+sqrt(b^2-4*a*c))/2/a;
%                 x = (x_p^2+y_p^2+1-2*y_p*y)/2/x_p;
%             end
%         end
        xyr = [xyr;x,y,r];
    end
end
            
end


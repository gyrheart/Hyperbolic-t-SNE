function [tx1,ty1,tx2,ty2] = two_arc_circle(x1,y1,r1,x2,y2,r2,q)
%Given two arcs (symmetric) parametrized by their circle centers and radii,
%this code finds their termination points

%find intersection of the two circles (the mother point of them)
[sx,sy] = intersection_two_circles(x1,y1,r1,x2,y2,r2);
[rho,d] = cart2pol(sx,sy);

if abs(r1 - r2)>=0.000001
    %error('arcs not symmetric!');
    %use general solver
    %S = two_arc_circle_general(x1,y1,r1,x2,y2,r2,q);
    options = optimset('MaxFunEvals',3000,'MaxIter',3000);
    if r1>=100
        x0 = [(2*d+3)/5*cos(rho), (2*d+3)/5*sin(rho), (2*d+3)/5*cos(rho), (2*d+3)/5*sin(rho)+0.1, 1.1*cos(rho), 1.1*sin(rho), 1*(1-d)];
    else
        x0 = [(2*d+3)/5*cos(rho), (2*d+3)/5*sin(rho)-0.05, (2*d+3)/5*cos(rho), (2*d+3)/5*sin(rho)+0.05, 1.1*cos(rho), 1.1*sin(rho), 0.8*(1-d)];
    end
    S = fsolve(@(input)seven_fun(input,x1,y1,r1,x2,y2,r2,q),x0,options);
tx1 = S(1);
ty1 = S(2);
tx2 = S(3);
ty2 = S(4);

else
    syms a b
    x = @(a,b,x1,x2,y1,y2) (a^2+b^2+1-b*(x2-x1)/(y2-y1)*(x1+x2)-b*(y1+y2))/(2*a-2*b*(x2-x1)/(y2-y1));
    r = @(a,b,x1,x2,y1,y2) sqrt(x(a,b,x1,x2,y1,y2)^2+((x2-x1)/(y2-y1))^2*(x(a,b,x1,x2,y1,y2)-(x1+x2)/2)^2+((y1+y2)/2)^2-(y1+y2)*(x2-x1)/(y2-y1)*(x(a,b,x1,x2,y1,y2)-(x1+x2)/2)-1);
    fun_r = @(a,b) r(a,b,x1,x2,y1,y2);
    [sola,solb] = vpasolve([(x1-a)^2+(y1-b)^2 == r1^2, a^2+b^2-1-2*sqrt(a^2+b^2)*cos(2*pi/q+pi-atan(abs(b/a))-atan(abs((y1-b)/(x1-a))))*fun_r(a,b) == 0],[1 0]);
    if sola^2+solb^2>1
        error('symmetric solution outside of unit circle')
    else
        sola = double(sola);
        solb = double(solb);
%         tx1 = x(sola,solb,x1,x2,y1,y2);
%         ty1 = -(x2-x1)/(y2-y1)*(tx1-(x1+x2)/2)+(y1+y2)/2;
        tx1 = sola;
        ty1 = solb;
        
        %find the other two coordinates by symmetry
        m = -(x2-x1)/(y2-y1);
        c = (y1+y2)/2 + (x2-x1)/(y2-y1)*(x1+x2)/2;
        if m<=0.000001
            tx2 = tx1;
            ty2 = 2*c-ty1;
        else
            tx2 = -2*m/(1+m^2)*(c-ty1-1/m*tx1)-tx1;
            ty2 = -2*m^2/(1+m^2)*(c-ty1-1/m*tx1)+2*c-ty1;
        end
    end
end
end


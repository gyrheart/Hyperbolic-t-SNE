function ftessellation_7_3
q = 7;
layers = 3;

%unit circle
r_c = 1;
disc = 500;
rho_c = linspace(0,2*pi-0.0001,disc);
x_c = cos(rho_c);
y_c = sin(rho_c);
% hfig = figure;
plot(x_c,y_c,'k-','LineWidth',1.5)
axis square
axis off
hold on

%first layer
sinpi_q = sin(pi/q);
cospi_q = cos(pi/q);
a = 1-4*sinpi_q^2;
b = -(2+8*sinpi_q^2-16*sinpi_q^2*cospi_q^2);
c = 1-4*sinpi_q^2;
% a = 1-(sec(pi/q))^2 * (sin(2*pi/q))^2;
% b = -2+4*(sin(2*pi/q))^2-2*(sec(pi/q))^2 * (sin(2*pi/q))^2;
% c = 1-(sec(pi/q))^2 * (sin(2*pi/q))^2;
% a = 1-(sec(pi/q))^2 * (cos(2*pi/q+pi/2))^2;
% b = -2+4*(cos(2*pi/q+pi/2))^2-2*(sec(pi/q))^2 * (cos(2*pi/q+pi/2))^2;
% c = 1-(sec(pi/q))^2 * (cos(2*pi/q+pi/2))^2;
s_square = (-b-sqrt(b^2-4*a*c))/2/a;
s = sqrt(s_square);  %vertex
h = (1+s^2)/2/s;   %x_coor of outside circle, y_coor = h*tan(pi/q)
r = sqrt(h^2/cospi_q^2-1);   %radius of outside circle
d_h = sqrt(1+r^2);   %distance of center of outside circle from origin

%plot the first layer
x_h = r*x_c + h;
y_h = r*y_c + h*tan(pi/q);
%only keep circles within current s
z_h = x_h.^2+y_h.^2;
x_h = x_h(z_h<=s_square);
y_h = y_h(z_h<=s_square);
plot(x_h,y_h,'k-','Linewidth',2/sqrt(1))
rotate_n_plot([x_h' y_h'],q,2/sqrt(1));
plot([0,s],[0,0],'k-','Linewidth',2/sqrt(1))
rotate_n_plot([0 0;s 0],q,2/sqrt(1));

plot(0,0,'k.','Markersize',15)
plot(s,0,'k.','Markersize',15/sqrt(1))
rotate_n_plot([s,0],q,15/sqrt(1));

%
%create a list of current conditions for add-on plottings
current_node = [s,0];
current_arcs = [h,h*tan(pi/q)];

for layer = 2:layers
next_node = [];
next_arcs = [];
all_arcs = [];
for k = 1:size(current_node,1)
    [xyr,theta] = point_surroundings(current_node(k,1),current_node(k,2),current_arcs(k,1),current_arcs(k,2),q);
    
    ite = 0;
    to_be_plot = {};
    for j = 1:q-1
        angle_j = theta+2*pi/q*j;  %angle from the origin-point line
        if abs(angle_j) >= 0.001
            ite = ite+1;
            x = xyr(ite,1);
            y = xyr(ite,2);
            r = xyr(ite,3);
            
            if r <= 100  %not a straight line
            x_h = r*x_c + x;
            y_h = r*y_c + y;
            else
            x_h = linspace(current_node(k,1), 2*current_node(k,1),100);
            y_h = linspace(current_node(k,2), 2*current_node(k,2),100);
            end
            %only keep circles within radius 1
            z_h = x_h.^2+y_h.^2;
            x_h = x_h(z_h<=1); %& z_h>=sqrt(node_x^2+node_y^2));
            y_h = y_h(z_h<=1); %& z_h>=sqrt(node_x^2+node_y^2));
            %keep circles depending on their polar angle with the
            %vertex (remove things that go through middle)
            [rho_all,~] = cart2pol(x_h-current_node(k,1),y_h-current_node(k,2));
            index = abs(rho_all+pi-angle_j)<=60/180*pi; %| abs(rho_all+pi+pi/2-angle_j)<=20/180*pi;
            x_h = x_h(index);
            y_h = y_h(index);
            %if any point on the circle is closer to the origin than the
            %node, discard the circle
            if sum(x_h.^2+y_h.^2 <current_node(k,1)^2+current_node(k,2)^2)>0
                xyr(ite,:) = [];
                ite = ite-1;
            else
%                 if layer == 3
%                 plot(x_h,y_h,'k-');
%                 rotate_n_plot([x_h' y_h'],q);
%                 end
                to_be_plot{ite,1} = x_h;
                to_be_plot{ite,2} = y_h;
            end
        end
        
        
    end
    if k==1
        to_be_plot_first = to_be_plot;
    end
    %xyr
    all_arcs = [all_arcs;  xyr];
    if size(xyr,1)==3
        %middle arcs' termination point
        [tx1,ty1,tx2,ty2] = two_arc_circle(xyr(2,1),xyr(2,2),xyr(2,3),xyr(3,1),xyr(3,2),xyr(3,3),q);
        if xyr(2,3)>=100
            [rho_temp,~] = cart2pol(current_node(k,1),current_node(k,2));
            next_node = [next_node;sqrt(tx1^2+ty1^2)*cos(rho_temp),sqrt(tx1^2+ty1^2)*sin(rho_temp)];
            next_arcs = [next_arcs;xyr(2,1),xyr(2,2)];
        else
            next_node = [next_node;tx1,ty1];
            next_arcs = [next_arcs;xyr(2,1),xyr(2,2)];
        end
        plot(next_node(end,1),next_node(end,2),'k.')
        %plot(tx2,ty2,'k.')
        %throw away points with radius >= termination points
        x_h = to_be_plot{2,1};
        y_h = to_be_plot{2,2};
        z_h = x_h.^2+y_h.^2;
        x_h = x_h(z_h<=tx1^2+ty1^2);
        y_h = y_h(z_h<=tx1^2+ty1^2);
        plot(x_h,y_h,'k-','Linewidth',2/sqrt(layer))
        rotate_n_plot([x_h' y_h'],q,2/sqrt(layer));
        
        %side two arcs' intersection points
        if size(all_arcs,1)~=size(xyr,1)
            x_temp = all_arcs(end-size(xyr,1),1);
            y_temp = all_arcs(end-size(xyr,1),2);
            r_temp = all_arcs(end-size(xyr,1),3);
            [sx,sy] = intersection_two_circles(xyr(1,1),xyr(1,2),xyr(1,3),x_temp,y_temp,r_temp);
            next_node = [next_node;sx,sy];
            next_arcs = [next_arcs;xyr(1,1),xyr(1,2)];
            plot(sx,sy,'r.')
            %throw away points with radius >= intersection points
            x_h = to_be_plot{1,1};
            y_h = to_be_plot{1,2};
            z_h = x_h.^2+y_h.^2;
            x_h = x_h(z_h<=sx^2+sy^2);
            y_h = y_h(z_h<=sx^2+sy^2);
            plot(x_h,y_h,'k-',2/sqrt(layer))
            rotate_n_plot([x_h' y_h'],q,2/sqrt(layer));

            %arc between previous node and the intersection point determined above
            [x_temp,y_temp,r_temp] = two_point_circle(current_node(k-1,1),current_node(k-1,2),sx,sy);
            x_temp = real(x_temp);
            y_temp = real(y_temp);
            r_temp = real(r_temp);
            x_h = r_temp*x_c + x_temp;
            y_h = r_temp*y_c + y_temp;
            %keep only points between the termination points - obtuse angle
            %between xuan's
            angles = acos(((x_h-current_node(k-1,1)).^2+(y_h-current_node(k-1,2)).^2+(x_h-sx).^2+(y_h-sy).^2-(sx-current_node(k-1,1)).^2-(sy-current_node(k-1,2)).^2)/2./sqrt((x_h-current_node(k-1,1)).^2+(y_h-current_node(k-1,2)).^2)./sqrt((x_h-sx).^2+(y_h-sy).^2));
            x_h = x_h(angles>=pi/2);
            y_h = y_h(angles>=pi/2);
            plot(x_h,y_h,'k-','Linewidth',2/sqrt(layer))
            rotate_n_plot([x_h' y_h'],q,2/sqrt(layer));
        end
            

    end
    if size(xyr,1)==4
        %middle two arcs' termination points
        [tx1,ty1,tx2,ty2] = two_arc_circle(xyr(2,1),xyr(2,2),xyr(2,3),xyr(3,1),xyr(3,2),xyr(3,3),q);
        next_node = [next_node;tx1,ty1;tx2,ty2];
        next_arcs = [next_arcs;xyr(2,1),xyr(2,2);xyr(3,1),xyr(3,2)];
        plot(tx1,ty1,'k.')
        plot(tx2,ty2,'k.')
        %throw away points with radius >= termination points
        x_h = to_be_plot{2,1};
        y_h = to_be_plot{2,2};
        z_h = x_h.^2+y_h.^2;
        x_h = x_h(z_h<=tx1^2+ty1^2);
        y_h = y_h(z_h<=tx1^2+ty1^2);
        plot(x_h,y_h,'k-','Linewidth',2/sqrt(layer))
        rotate_n_plot([x_h' y_h'],q,2/sqrt(layer));
        
        x_h = to_be_plot{3,1};
        y_h = to_be_plot{3,2};
        z_h = x_h.^2+y_h.^2;
        x_h = x_h(z_h<=tx2^2+ty2^2);
        y_h = y_h(z_h<=tx2^2+ty2^2);
        plot(x_h,y_h,'k-','Linewidth',2/sqrt(layer))
        rotate_n_plot([x_h' y_h'],q,2/sqrt(layer));

        %side two arcs' intersection points
        if size(all_arcs,1)~=size(xyr,1)
            x_temp = all_arcs(end-size(xyr,1),1);
            y_temp = all_arcs(end-size(xyr,1),2);
            r_temp = all_arcs(end-size(xyr,1),3);
            [sx,sy] = intersection_two_circles(xyr(1,1),xyr(1,2),xyr(1,3),x_temp,y_temp,r_temp);
            sx = real(sx);
            sy = real(sy);
            next_node = [next_node;sx,sy];
            next_arcs = [next_arcs;xyr(1,1),xyr(1,2)];
            plot(sx,sy,'k.')
            %throw away points with radius >= intersection points
            x_h = to_be_plot{1,1};
            y_h = to_be_plot{1,2};
            z_h = x_h.^2+y_h.^2;
            x_h = x_h(z_h<=sx^2+sy^2);
            y_h = y_h(z_h<=sx^2+sy^2);
            plot(x_h,y_h,'k-','Linewidth',2/sqrt(layer))
            rotate_n_plot([x_h' y_h'],q,2/sqrt(layer));

            %arc between previous node and the intersection point determined above
            [x_temp,y_temp,r_temp] = two_point_circle(current_node(k-1,1),current_node(k-1,2),sx,sy);
            x_h = r_temp*x_c + x_temp;
            y_h = r_temp*y_c + y_temp;
            %keep only points between the termination points - obtuse angle
            %between xuan's
            angles = acos(((x_h-current_node(k-1,1)).^2+(y_h-current_node(k-1,2)).^2+(x_h-sx).^2+(y_h-sy).^2-(sx-current_node(k-1,1)).^2-(sy-current_node(k-1,2)).^2)/2./sqrt((x_h-current_node(k-1,1)).^2+(y_h-current_node(k-1,2)).^2)./sqrt((x_h-sx).^2+(y_h-sy).^2));
            x_h = x_h(angles>=pi/2);
            y_h = y_h(angles>=pi/2);
            plot(x_h,y_h,'k-','Linewidth',2/sqrt(layer))
            rotate_n_plot([x_h' y_h'],q,2/sqrt(layer));
        end

    end
end
%intersection between first arc and rotated last arc
[x_temp,y_temp] = rotate_pt(all_arcs(end,1),all_arcs(end,2),-2*pi/q);
r_temp = xyr(end,3);
[sx,sy] = intersection_two_circles(all_arcs(1,1),all_arcs(1,2),all_arcs(1,3),x_temp,y_temp,r_temp);
next_node = [next_node;sx,sy];
next_arcs = [next_arcs;xyr(1,1),xyr(1,2)];
plot(sx,sy,'k.')
%throw away points with radius >= intersection points
x_h = to_be_plot_first{1,1};
y_h = to_be_plot_first{1,2};
z_h = x_h.^2+y_h.^2;
x_h = x_h(z_h<=sx^2+sy^2);
y_h = y_h(z_h<=sx^2+sy^2);
plot(x_h,y_h,'k-','Linewidth',2/sqrt(layer))
rotate_n_plot([x_h' y_h'],q,2/sqrt(layer));
%connect the intersection point with the node
x_h = to_be_plot{end,1};
y_h = to_be_plot{end,2};
z_h = x_h.^2+y_h.^2;
x_h = x_h(z_h<=sx^2+sy^2);
y_h = y_h(z_h<=sx^2+sy^2);
plot(x_h,y_h,'k-','Linewidth',2/sqrt(layer))
rotate_n_plot([x_h' y_h'],q,2/sqrt(layer));

current_node = next_node;
current_arcs = next_arcs;
[~,ind] = sort(current_node(:,2));
current_node = real(current_node(ind,:));
current_arcs = current_arcs(ind,:);

%close the remaining points
for ii = 1:size(current_node,1)-1
    x1_temp = current_node(ii,1);
    y1_temp = current_node(ii,2);
    x2_temp = current_node(ii+1,1);
    y2_temp = current_node(ii+1,2);
    [x_temp,y_temp,r_temp] = two_point_circle(x1_temp,y1_temp,x2_temp,y2_temp);
    x_temp = real(x_temp);
    y_temp = real(y_temp);
    r_temp = real(r_temp);
    x_h = r_temp*x_c + x_temp;
    y_h = r_temp*y_c + y_temp;
    %keep only points between the termination points - obtuse angle
    %between xian's
    angles = acos(((x_h-x1_temp).^2+(y_h-y1_temp).^2+(x_h-x2_temp).^2+(y_h-y2_temp).^2-(x2_temp-x1_temp).^2-(y2_temp-y1_temp).^2)/2./sqrt((x_h-x1_temp).^2+(y_h-y1_temp).^2)./sqrt((x_h-x2_temp).^2+(y_h-y2_temp).^2));
    x_h = x_h(angles>=pi/2);
    y_h = y_h(angles>=pi/2);
    plot(x_h,y_h,'k-','Linewidth',2/sqrt(layer))
    rotate_n_plot([x_h' y_h'],q,2/sqrt(layer));
    
    plot(current_node(ii,1),current_node(ii,2),'k.','Markersize',15/sqrt(layer))
    rotate_n_plot([current_node(ii,1),current_node(ii,2)],q,15/sqrt(layer));
end
x1_temp = current_node(end,1);
y1_temp = current_node(end,2);
[x2_temp,y2_temp] = rotate_pt(current_node(1,1),current_node(1,2),2*pi/q);
[x_temp,y_temp,r_temp] = two_point_circle(x1_temp,y1_temp,x2_temp,y2_temp);
x_h = r_temp*x_c + x_temp;
y_h = r_temp*y_c + y_temp;
%keep only points between the termination points - obtuse angle
%between xian's
angles = acos(((x_h-x1_temp).^2+(y_h-y1_temp).^2+(x_h-x2_temp).^2+(y_h-y2_temp).^2-(x2_temp-x1_temp).^2-(y2_temp-y1_temp).^2)/2./sqrt((x_h-x1_temp).^2+(y_h-y1_temp).^2)./sqrt((x_h-x2_temp).^2+(y_h-y2_temp).^2));
x_h = x_h(angles>=pi/2);
y_h = y_h(angles>=pi/2);
plot(x_h,y_h,'k-','Linewidth',2/sqrt(layer))
rotate_n_plot([x_h' y_h'],q,2/sqrt(layer));

plot(current_node(end,1),current_node(end,2),'k.','Markersize',15/sqrt(layer))
rotate_n_plot([current_node(end,1),current_node(end,2)],q,15/sqrt(layer));
end
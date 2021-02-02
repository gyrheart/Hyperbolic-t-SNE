function [] = rotate_n_plot(pts,q,linewidth)
%This function takes in a vector of points, rotate them around the origin,
%and then plot the rotated points
rho = linspace(0,2*pi,q+1);
rho = rho(2:end-1);
if size(pts,1)==1
    [rho_all,d_all] = cart2pol(pts(:,1),pts(:,2));
    for i = 1:q-1
        plot(d_all*cos(rho_all+rho(i)),d_all*sin(rho_all+rho(i)),'k.','MarkerSize',linewidth)
    end
else
    [rho_all,d_all] = cart2pol(pts(:,1),pts(:,2));
    for i = 1:q-1
        plot(d_all.*cos(rho_all+rho(i)),d_all.*sin(rho_all+rho(i)),'k-','Linewidth',linewidth)
    end
end
end


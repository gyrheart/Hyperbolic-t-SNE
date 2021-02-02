function fStereographicPlot(Y)

Y = fRescaleAngle(Y);
x=sin(Y(:,2)).*cos(Y(:,3));
y=sin(Y(:,2)).*sin(Y(:,3));
z=cos(Y(:,2));
color_x1 = fRescale(x,[0,1]); % marker color
color_y1 = fRescale(y,[0,1]);
color_z1 = fRescale(z,[0,1]);
RescaleR= fRescale(Y(:,1),[5 15]); % marker size
theta=0:0.1:1*pi;
phi=0:0.1:2*pi;

% plot grids

for phi1=0:0.1*pi:2*pi
    plot(sin(theta)*cos(phi1)./(1+abs(sin(theta)*sin(phi1))),...
        cos(theta)./(1+abs(sin(theta)*sin(phi1))),':','color',[0.5,0.5,0.5],'markersize',2)
    hold on
end

for theta1=0:0.1*pi:1*pi
    plot(sin(theta1)*cos(phi)./(1+abs(sin(theta1)*sin(phi))),...
        cos(theta1)./(1+abs(sin(theta1)*sin(phi))),':','color',[0.5,0.5,0.5],'markersize',2)
    hold on
end

% plot points
for i=1:size(Y,1)    
   if y(i)<0
        plot(x(i)/(1+abs(y(i))),z(i)/(1+abs(y(i))),'s','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[color_x1(i),color_y1(i),color_z1(i)],'MarkerSize',RescaleR(i),'LineWidth',0.3)
   end   
    hold on   
end
for i=1:size(Y,1)    
    if y(i)>0
        plot(x(i)/(1+abs(y(i))),z(i)/(1+abs(y(i))),'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[color_x1(i),color_y1(i),color_z1(i)],'MarkerSize',RescaleR(i),'LineWidth',0.5)
    end   
    hold on   
end
hold off

axis square
axis off
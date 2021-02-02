
function fPlotPoincareDisk(Rmax,interval,nline)
% clc
% figure(30)
% Rmax = 1;
% interval = 0.2;
nbins = floor(Rmax/interval);
% nline = 3e2;

rline = zeros(nbins+1,1);
for k = 1:nbins
    r_new = fsolve(@(x) cosh(interval) -( cosh(rline(k))*cosh(x) - ...,
        sinh(rline(k))*sinh(x)),Rmax);
    rline(k+1) = r_new; 
    r_poincare = tanh(r_new/2);
    npoints = nline + 300*r_poincare;
    angles = 0:2*pi/npoints:2*pi+2*pi/npoints;
    plot(r_poincare*cos(angles),r_poincare*sin(angles),'k-','markersize',0.1)
    hold on
end
hold off
R_range = tanh(Rmax/2);
axis([-R_range,R_range,-R_range R_range])
axis square
axis off

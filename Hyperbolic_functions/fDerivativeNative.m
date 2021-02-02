function Y = fDerivativeNative(X,varargin)

paramNames = {'Range'};
paramDflts = {[]};
[range] = internal.stats.parseArgs(paramNames, paramDflts, varargin{:});
if isempty(range)     
    range = 1:length(X);
end

[n,p] = size(X);
Y = zeros(n,n,p);
cos_angle = cos(X(range,p)-X(:,p)');
for count_angle = p-1:-1:2
   cos_angle = sin(X(range,count_angle))*sin(X(:,count_angle)').*cos_angle+ ...,
       cos(X(range,count_angle))*cos(X(:,count_angle)');
end
cosh_angle = cosh(X(range,1))*cosh(X(:,1)')-sinh(X(range,1))*sinh(X(:,1)').*cos_angle;
Y(range,:,1) = 1./sqrt(cosh_angle.^2-1).*(sinh(X(range,1))*cosh(X(:,1)')-cosh(X(range,1))*sinh(X(:,1)').*cos_angle);
for count_angle = p:-1:2
    if count_angle == p
        Y(range,:,count_angle) = 1./sqrt(cosh_angle.^2-1).*(sinh(X(range,1))*sinh(X(:,1)')).*sin(X(range,count_angle)-X(:,count_angle)') ;
        cos_angle = cos(X(:,count_angle)-X(:,count_angle)');
    else
        Y(range,:,count_angle) = -1./sqrt(cosh_angle.^2-1).*(sinh(X(range,1))*sinh(X(:,1)')).* ...,
                        (cos(X(range,count_angle))*sin(X(:,count_angle)').*cos_angle - sin(X(range,count_angle))*cos(X(:,count_angle)'));
        cos_angle = sin(X(range,count_angle))*sin(X(:,count_angle)').*cos_angle+cos(X(range,count_angle))*cos(X(:,count_angle)');
    end
    for ii = 2:count_angle-1
        Y(range,:,count_angle) = (sin(X(range,ii))*sin(X(:,ii)')).*Y(range,:,count_angle);
    end
end
Y = real(Y); 
for k = 1:size(Y,3)
    for kk = 1:size(Y,1)
        Y(kk,kk,k) = 0;
    end
end

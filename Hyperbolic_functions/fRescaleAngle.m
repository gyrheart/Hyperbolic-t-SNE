function Y = fRescaleAngle(X)
% Rescale all the angle coordinates into single periods. 
d = size(X,2);
Y = X;
for k = 2:d
    Y(:,k) = fRescalePeriod(Y(:,k) ,[0,2*pi]);
end
change_sign  = zeros(size(X,1),1);
for k =  2:d-1
    Y(:,k) = fRescalePeriod(Y(:,k)+change_sign*pi ,[0,2*pi]);
    change_sign = Y(:,k)>pi;
    Y(change_sign,k) = 2*pi-Y(change_sign,k);
   
end
    Y(:,d) = fRescalePeriod(Y(:,d)+change_sign*pi ,[0,2*pi]);
end
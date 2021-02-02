function Y = fCart2Polar(X)
[r,c] = size(X);
Y = ones(size(X));
Y(:,1) = sqrt(sum((X.^2),2));
temp = Y(:,1);
if c>1
    for k = 1:c-2    
        theta = acos(X(:,c-k+1)./temp);
        Y(:,k+1) = theta;
        temp = temp.*sin(theta);
    end
    for k = 1:r
        if X(k,2)/temp(k) > 0
            Y(k,c) = acos(X(k,1)/temp(k));
        else
            Y(k,c) = 2*pi - acos(X(k,1)/temp(k));
        end
    end
end


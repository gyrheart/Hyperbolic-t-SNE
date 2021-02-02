function Y = fPolar2Cart(X)
[r,c] = size(X);
Y = ones(size(X));
Cos_angle = cos(X(:,2:end));
Sin_angle = sin(X(:,2:end));
temp = X(:,1);
for k = 1:c-1
    Y(:,c-k+1) = temp;
    if k<c-1
        temp = temp.*sin(X(:,k+1));
    end
end
Y(:,1) = temp.*cos(X(:,end));
Y(:,2) = temp.*sin(X(:,end));
for k = 1:c-2
    Y(:,c-k+1) = Y(:,c-k+1).*cos(X(:,k+1));
end

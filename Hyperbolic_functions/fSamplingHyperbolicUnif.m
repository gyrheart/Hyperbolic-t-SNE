function Y = fSamplingHyperbolicUnif(N,d,R,MinRatio)
% Uniform distribtion of angles
cart_pos = zeros(N,d);
for k = 1:N
    cart_pos(k,:) = randn(1,d);
    cart_pos(k,:) = cart_pos(k,:)/norm(cart_pos(k,:));
end
Y = fCart2Polar(cart_pos);
k = 0;
while k<N
        r  = MinRatio+rand(1)*(1-MinRatio);
        y = rand(1)*sinh(R)^(d-1);
        if sinh(R*r)^(d-1)>=y
            k=k+1;
           Y(k,1) = R*r;  
        end
end
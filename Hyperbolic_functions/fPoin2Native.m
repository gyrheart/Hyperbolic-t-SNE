function Y = fPoin2Native(X)
Y_Polar = fCart2Polar(X);
Y = Y_Polar;
Y(:,1) = 2*atanh(Y(:,1));

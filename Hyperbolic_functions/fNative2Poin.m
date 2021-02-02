function Y = fNative2Poin(X)
Y_polar = X;
Y_polar(:,1) = tanh(Y_polar(:,1)/2);
Y = fPolar2Cart(Y_polar);
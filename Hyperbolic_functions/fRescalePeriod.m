function Y = fRescalePeriod(X,range)
% Rescale the input value into a given range 
l = range(1);
r = range(2);
delta = r-l;
for k =  1:length(X)
    if X(k)<l
        X(k) = X(k) + delta;
        while X(k) <l
            X(k) = X(k) + delta;
        end
    
    elseif X(k)>r
        X(k) = X(k) - delta;
        while X(k) >r
            X(k) = X(k) - delta;
        end
    end
    
end
Y = X;
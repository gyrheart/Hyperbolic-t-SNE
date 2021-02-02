function Y = fNativeMoveCenter(X,rootPoint)
    Y_poin = fNative2Poin(X);
    center_pos = Y_poin(rootPoint,:);
    Y_new = fPoincareTransCenter(Y_poin,center_pos');
    Y = fPoin2Native(Y_new);
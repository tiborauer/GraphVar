function D = charpath_B_neg(W)
    W=(-W.*(W<0));
    D = distance_bin(W);
    D = charpath(D);

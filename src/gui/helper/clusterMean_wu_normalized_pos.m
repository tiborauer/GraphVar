function D = clusterMean_wu_normalized_pos(W)
    W=( W.*(W>0));
    W=W./max(abs(W(:)));    %scale by maximal weight
    D = clustering_coef_wu(W);

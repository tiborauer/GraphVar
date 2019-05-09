function D = clusterMean_bu_neg(W)
        W =(-W.*(W<0));
    D = mean(clustering_coef_bu(W));

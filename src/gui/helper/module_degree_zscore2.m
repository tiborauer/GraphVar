function D = module_degree_zscore2(W)
    sum_d = cell(100,1);
    for iter = 1:100
        d = modularity_und(W);
        sum_d = module_degree_zscore(W,d);
        sum_d_all(:,iter) = sum_d;
    end
    D = mean(sum_d,2);

    %D = modularity_und(W);
    %D = module_degree_zscore(W,D);

function Hneg = hneg_Louvain(W)
    Ci = modularity_louvain_cOut_und(W);
    [~, Hneg] = diversity_coef_sign(W, Ci);
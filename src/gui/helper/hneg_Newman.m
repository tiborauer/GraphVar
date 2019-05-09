function Hneg = hneg_Newman(W)
    Ci = modularity_cOut_und(W);
    [~, Hneg] = diversity_coef_sign(W, Ci);
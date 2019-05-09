function Hpos = hpos_Louvain(W)
    Ci = modularity_louvain_cOut_und(W);
    [Hpos, ~] = diversity_coef_sign(W, Ci);
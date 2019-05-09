function Hpos = hpos_Newman(W)
    Ci = modularity_cOut_und(W);
    [Hpos, ~] = diversity_coef_sign(W, Ci);
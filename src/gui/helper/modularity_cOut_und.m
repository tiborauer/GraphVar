function [C, agree] = modularity_cOut_und(W)
   sum_c = cell(1000,1);
   for iter = 1:1000
       [ci, ~] = modularity_und(W);
       sum_c{iter} = ci;
   end
   agree = agreement(sum_c);
   tau = 0;
   reps = 70;
   C = consensus_und(agree, tau, reps);

function Q= modularity_finetune_QOut_und_sign(W) 
   sum_q = cell(100,1);
   for iter = 1:100
       [~, q] = modularity_finetune_und_sign(W);
       sum_q{iter} = q;
   end
   Q = mean(cell2mat(sum_q));
   
   %[~,Q] = modularity_finetune_und_sign(W);



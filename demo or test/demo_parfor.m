%% parfor_demo

%% template
pf_iters = 4; 
fname_var = sprintf('pf-%d-whatever.mat',pf_iters);
output_F = cell(pf_iters,1);


parpool('local',pf_iters);%數字代表核心數

parfor k = 1:pf_iters
    
    
end
delete(gcp('nocreate')); %關掉parfor
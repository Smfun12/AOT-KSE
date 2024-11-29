close all;
[p] = load('save_data/p.mat');
p = p.p;

[vars] = load('save_data/vars.mat');
vars = vars.vars;

plotFinalErrorForVars(vars, p)
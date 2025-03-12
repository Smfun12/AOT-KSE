err = load("err.mat");
err = err.errors;
err = 1/size(err,1) * sum(err);
figure;
p.dt = 0.01;
time_axis = p.dt:p.dt:p.dt*length(err);
semilogy(time_axis, err, "-o", 'LineWidth', 3);
xlabel("Time, $t$", "Interpreter","latex")
ylabel("AOT error, $\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex")
legend("Lagrangian" + "(#sensors="+ 32 + ", a=" + 40 + ")");
fontsize(48, "points")

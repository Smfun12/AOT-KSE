clear; clc; close all;
var.nu = 1;
u_x_star = load("matlab.mat");
u_x_star = u_x_star.u_x_star;
var.c = 0.03;
p.dx = 0.0982;
x = [];
y = [];
for mu=1:1000
bracket = (-4/3 * (2/var.nu - mu + u_x_star)).^(3/4);
constants = var.nu^(1/4) / (mu*var.c^(1/4));

h_hat = bracket * constants;
x = [x, mu];


rho = 3/4*(mu^4*var.c*h_hat.^4/var.nu).^(1/3);
final_bracket = 2/var.nu - mu + u_x_star + rho; 

max_value = max(final_bracket);

disp("Mu=" + mu + ", bracket_value=" + max_value)

nsensors = sum(1./h_hat)*p.dx;
y = [y, nsensors];
end

plot(x, real(y), "LineWidth", 2)
ylabel("#sensors")
xlabel("\mu", "Interpreter","tex")
fontsize(24, "points")
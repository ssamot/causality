function g_dev1 = g_dev2_2pi_atan(v)
% calculates the first order derivative of the '2*atan/pi' function

g_dev1 = -pi * v .* g_dev1_2pi_atan(v).^2;
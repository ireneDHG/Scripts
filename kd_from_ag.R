#script to calculate the Kd from the binding AG

R <- 8.314
T <- 298
energy <- -4.7 #kcal/mol

kd <- exp(energy/0.592) #M units
kd <- kd*1000000
kd

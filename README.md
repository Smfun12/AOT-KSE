# AOT–KSE Data Assimilation

This repository provides MATLAB scripts for simulating the Azouani–Olson–Titi (AOT) nudging data assimilation algorithm applied to the one-dimensional Kuramoto–Sivashinsky Equation (KSE).
The implementation is designed to study synchronization, convergence, and reconstruction of the true system state using conventional (e.g., Lagrangian and pseudo-Lagrangian) and optimal sensor placement/movement.

# Usage

## Running a Simulation

The entry point for running simulations is

```bash
KSE_inter.m
```

## Modifying System Parameters

To change:

- KSE parameters (e.g., viscosity, domain length)
- Simulation settings
- Plotting options (solution, error, sensors)
edit the following file:

```bash
default_config/initDefaultEnv.m
```

## Selecting Sensor Types

To use various sensor types (e.g., Lagrangian, pseudo-Lagrangian, and/or Directed sensors), open

```bash
default_config/DataAssimilationVariables_KSE.m
```

and uncomment the desired sensor configuration.

# References

- [Azouani, A., Olson, E., & Titi, E. S.
Continuous Data Assimilation Using General Interpolant Observables](https://arxiv.org/abs/1304.0997)

- [Ning, Ning, and Collin Victor. An Assessment of Ensemble Kalman Filter and Azouani–Olson–Titi Algorithms for Data Assimilation: A Comparative Study](https://arxiv.org/abs/2407.17424)

# Credits

- [Original author of the code and contributor - Collin Victor](https://github.com/cvictor2/AOT_CDA_2D_NSE/tree/main/KSE)
- [Supervisor - Zhao Pan](https://uwaterloo.ca/mechanical-mechatronics-engineering/profile/z79pan)

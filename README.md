# handy.atlantis 
## A helping hand for calibrating Atlantis models 
A package for running multiple simultaneous instances of the Atlantis model from a Docker image, as well as updating parameters in an easy manner. It has basic plotting functions for a quick look at the output of several runs.

Current functions included in the package:
- **update_prm.R**: simple way of updating parameters with a single value.
- **adv_update_prm.R**: function that changes parameters to which multiple values are assigned (e.g., diet matrix).
- **run_docker_instances.R**: a function that starts a Docker container for each input file (limited to biology.prm for now).
- **massplot.R**, **rel_mass_plot.R**: plotting functions for comparing output from multiple instances.

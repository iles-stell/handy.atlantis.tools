# handy.atlantis 
## A helping hand for calibrating Atlantis models 
A package for running multiple simultaneous instances of the Atlantis model from a Docker image, as well as updating parameters in an easy manner. It has basic plotting functions for a quick look at the output of several runs.

Current functions included in the package:
- **update_prm.R**: simple way of updating parameters with a single value.
- **adv_update_prm.R**: function that changes parameters to which multiple values are assigned (e.g., diet matrix).
- **run_docker_instances.R**: a function that starts a Docker container for each input file (limited to biology.prm for now). This requires a small modification of the Run.sh file to include a variable input file (```$PRM_FILE```) and an output file (```$OUTPUT_DIR```), like so:
```
atlantisMerged -i final_with_ice_input_v2.nc 0 -o output_f_.nc -r EA_run.prm -f EA_force.prm -p EA_physics.prm -b $PRM_FILE -h EA_harvest_nofishing.prm -s AntarcticGroups_v2_basicfoodweb.csv -d $OUTPUT_DIR -m EA_migrations.csv
```
- **massplot.R**, **rel_mass_plot.R**: plotting functions for comparing output from multiple instances.
- **get_metric**: extracts parameters (input files) and final biomass values (output files) to create a dataset for later analysis.
- **optimise_bayesian** (WIP): trial version of a small calibration system for Atlantis parameters. It uses Bayesian optimisation to find ideal parameter value based on previous runs.
- **whole_shebang** (WIP): trial version of self-updating process for Atlantis calibraiton (optimises parameter -> updates input file -> runs updated files in Docker -> optimises parameter, and so on). 

## Planned updates
- [ ] More plotting options for PREBAL checks
- [ ] Function for automated calibration of most influential biological parameters 

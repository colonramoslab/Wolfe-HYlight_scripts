# Scripts for HYlight analysis in worms
Written by Aaron Wolfe -- @beowulfey on github. 

These FIJI macros were used for analyzing HYlight data in C. elegans as described in Wolfe, A.D. et al, 2023. 

Export Z Stack Ratios: used to capture pixel data for neurons in strains expressing pan-neuronal HYlight or HYlight-RA. Neuron regions are thresholded on each Z slice and the XY data is exported per slice. This can then be used to produce histograms of the ratiometric distributions, or determine the average/median/standard distribution, etc. 

Interpolate ROIs: this script contains a few short macros to make processing the lower-mag data a little easier. It allows you to interpolate between ROI locations over time frames for single Z images (also works for max projections). Originally written to account for worm movement over time. 

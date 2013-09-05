#!/bin/bash
cd matlab-code/Code/
matlab -r "run_igci_gaussian_integral valid; exit"
matlab -r "run_igci_uniform_integral valid; exit"
matlab -r "run_lingam valid; exit"

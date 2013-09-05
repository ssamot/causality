#!/bin/bash
cd matlab-code/Code/
matlab -r "run_igci_gaussian_integral train; exit"
matlab -r "run_igci_uniform_integral train; exit"
matlab -r "run_lingam train; exit"

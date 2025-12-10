#!/bin/tcsh
setenv RHEL_USER $USER
apptainer --verbose build -F rhel8.sif rhel8.def
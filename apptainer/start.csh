#!/bin/tcsh
setenv APPTAINER_RUN_DIR `mktemp -d`

# resolve the location of this script to determine the image location
set SCRIPT=`readlink -f "$0"`
set SCRIPTPATH=`dirname "$SCRIPT"`

# find the actual image the symlink points to - the file will remain if a new
# image is created, keeping current runs alive
setenv APPTAINER_IMAGE `realpath ${SCRIPTPATH}/rhel8.sif`

# if rhel8.sif does not exist, build it
if ( ! -f $APPTAINER_IMAGE ) then
  echo "Image not found, building..."
  $SCRIPTPATH/create.csh
endif
# default paths for your tools here add the path you would require for example:
#setenv APPTAINER_BINDPATH "/edadk,/softs,/dkits"

# always bind the run directory
setenv APPTAINER_BINDPATH "${APPTAINER_RUN_DIR}:/run"

# check whether a homes folder exists and add it to the path if so
if ( -d /home ) then
  setenv APPTAINER_BINDPATH "${APPTAINER_BINDPATH},/home"
endif

# check whether a scratch folder exists and add it to the path if so
if ( -d /scratch ) then
  setenv APPTAINER_BINDPATH "${APPTAINER_BINDPATH},/scratch"
endif


echo Starting apptainer from ${APPTAINER_IMAGE}...
echo "  Paths mounted:"

foreach i ( $APPTAINER_BINDPATH:as/,/ / )
  echo "  - $i"
end

apptainer run $APPTAINER_IMAGE
rm -rf ${APPTAINER_RUN_DIR}

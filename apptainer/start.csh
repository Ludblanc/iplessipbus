#!/bin/tcsh
# Copyright (c) 2025 Ludovic Damien Blanc

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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

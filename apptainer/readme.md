# Apptainer Environment (Running IPBus Tools)

We provide an Apptainer/Singularity container to ensure consistent execution of IPBus software across EPFL EDA‑compatible machines.
This is not used for RTL neither simulation puposes yet but really to send IPbus packet throught ethernet to an ASIC/FPGA.

### **Creating the `.sif` container image**

Run the creation script (only onces):

```tcsh
./create.csh
```

This will build the Apptainer image containing all required IPBus and Python tooling.

### **Launching the container**

Start the environment using:

```tcsh
./path_to_here/start.csh
```

This script enters the preconfigured environment with all software available.

### **Using Python inside the container**

The container provides the correct IPBus‑compatible Python version:

* `python3.11`

When running scripts:

```bash
python3.11 my_script.py
```

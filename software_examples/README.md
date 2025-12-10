# Software

This section demonstrates a simple example that writes data into a memory block and reads it back line‑by‑line using the *Romeo and Juliet* text.

### **Launching the Apptainer environment**

All software runs inside the provided Apptainer container. Start it with:

```bash
./../apptainer/start.csh
```

This loads the full IPBus stack and required Python version.

### **Address table and decoder generation**

The memory map of your payload logic is defined in:

* `address_table.xml`

From this file, generate the VHDL decoder using:

* `gen_ipbus_addr_decode.py`

This produces:

* `address_decoder.vhd` → **must be added to your RTL project** so the firmware matches the software’s address space.

### **Python access to memory‑mapped registers**

Python scripts can interact with the FPGA registers and memories using the address table definitions. For detailed information, refer to:

* **IPBus User Guide:** [https://ipbus.web.cern.ch/doc/user/html/software/uhalQuickTutorial.html](https://ipbus.web.cern.ch/doc/user/html/software/uhalQuickTutorial.html)

### **Running the example**

Once inside Apptainer, run:

```bash
python3.11 basic_test.py
```

This script writes the *Romeo and Juliet* text to memory and then reads it back line‑by‑line, all of this via ethernet and ipbus.


# IPbus

Implementation of the full IPbus project, with integration of verilog-ethernet, and with provided example slaves.

MII stands for Media Independent Interface. This is the interface between the Ethernet Physical chip and the MAC module. There are several variations of this interface, each with different I/O requirements and speeds: 

|MII|RMII|GMII|RGMII|
|:----|:----|:----|:----|
|13I/Os|8I/Os|22I/Os|12I/Os|
|25MHz|50MHz|125MHz|125MHz|
|100Mbps|100Mbps|1Gbps|1Gbps|  
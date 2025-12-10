# Verilog-ethernet 

Test of verilog-ethernet alone. It decodes Ethernet/IP/UDP packets, and echoes them. 

MII stands for Media Independent Interface, and it's the connection between the Ethernet Physical chip and the MAC module. There are different options: 

|MII|RMII|GMII|RGMII|
|:----|:----|:----|:----|
|13I/Os|8I/Os|22I/Os|12I/Os|
|25MHz|50MHz|125MHz|125MHz|
|100Mbps|100Mbps|1Gbps|1Gbps|  
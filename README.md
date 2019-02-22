VHDL codes to generate GPS L1 C/A and Galileo E1 and E5 PRNs and signals. The project is implemented with Xilinx ISE 14.7 but it should be easy to migrate it to Vivado. For Altera platforms, some IP cores (mainly RAM memories) must be adapted. Includes Xilinx ISE testbench and wave configuration files, and Matlab scripts to chech the simulation results (see [here](https://github.com/danipascual/GNSS-matlab)).

All the contents were developed for the [passive remote sensing group (RSLab)](https://prs.upc.edu/) as a part of the [Remote Sensing Laboratory](http://www.tsc.upc.edu/en/research/rslab), a research line of the [CommmSensLab Group](http://www.tsc.upc.edu/en/research/commsenslab) at the [Signal Theory and Communications Department (TSC)](http://www.tsc.upc.edu/en) of the [Universitat Politècnica de Catalunya (UPC)](http://www.upc.edu/?set_language=en).

New versions of this program may be found at [GitHub](https://github.com/danipascual/GNSS-VHDL). 

## Main contents
### \source
#### \source\GNSS_prn
Generate a complete **unsampled** PRN sequence of a specific satellite cyclically repeated **from the begining** using LFSRs (except for E1B and E1C which are stored in RAMs).

+ E1_generator.vhd: Galileo E1B and E1C.
+ E5_generator.vhd: Galileo E5aI, E5aQ, E5bI, E5bQ.
+ L1_CA_generator.vhd: GPS L1 C/A.
+ L1_CA_generator.vhd: GPS L1 C/A.
+ L5_generator.vhd: GPS L1 C/A.

#### \source\GNSS_signal
Generates the GNSS signals of a specific satellite cyclically repeated **starting from any desired PRN chip** at **any desired frequency multiple of 1.023**. The former can be changed dynamically, the latter is fixed in the synthesis. In future versions of the program I will show how to use the same entities to generate several signals synchronized at different frequencies so as to for example perform simultaneously a downsampled coarse acquistion and a fine tracking using the full bandwidth replica.

+ E1OS_signal_generator.vhd: Applies a synchronized BOC modulation to the PRN.
+ E5_signal_generator.vhd: Applies a synchronized BOC modulation to the PRN.
+ E1OS_top.vhd: Generates the E1OS signal **from the begining**.
+ E5_top.vhd: Generates the E5 signal **from the begining**.
+ L1CA_mem.vhd: Generates the C/A signal **from any desired PRN chip**.
+ E1OS_mem.vhd: Generates the E1OS signal **from any desired PRN chip**.
+ E5_mem.vhd: Generates the E5 signal **from any desired PRN chip**.

#### \source\shared
+ LFSR_generator.vhd: Generic entity used to generate any GNSS PRN.
+ addr_decoder.vhd: Decodes a PRN chip number to the a BOC chip reference.

#### \matlab
Matlab scripts to check the PRNs and signals generated with the codes above. The Matalb GNSS codes used as reference can be obtained [here](https://github.com/danipascual/GNSS-matlab).

## Licence
You may find a specific licence files in each directory.

## Contact
Daniel Pascual (daniel.pascual at protonmail.com)
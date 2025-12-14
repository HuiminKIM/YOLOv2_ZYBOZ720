## FPGA System Integration & XSA Generation

This section outlines the process of integrating the generated `yolov2_accelerator` IP into the FPGA system, performing synthesis and implementation, and finally generating the **XSA file** containing the bitstream.

1. **Create a New Project**: Launch Vivado and create a **new project** (separate from the one created in the `01_Source` step).
    * > **Important**: During the project creation wizard, do **not** add any Verilog sources or constraint files.
    * Simply select the **ZYBO Z7-20** as the target board and complete the project creation.

2. **Next Steps**: Once the project is ready, proceed with the tasks described in the following folders/sections:
    * `01_Block_Design`
    * `02_Synthesis & Implementation`

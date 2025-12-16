## 02. Synthesis, Implementation & XSA Generation

This section covers the process of synthesizing and implementing the HDL wrapper (the complete FPGA system created in the Block Design) to extract an **XSA file** containing the bitstream. Follow the steps below:

1. **Generate Bitstream**: Click **Generate Bitstream** under the **Program and Debug** section in the Flow Navigator.
    * If a dialog appears stating there are no implementation results, click **Yes** (or **OK**). Vivado will automatically trigger the synthesis and implementation processes.
2. **Generate Scripts**: When the launch runs window appears, select **Generate scripts only** and click **OK**.
<br>

<p align="center">
  <img src="generate_scripts.png" alt="Generate Scripts" width="500">
</p>
<br>

3. **Verify Runs**: You will see that scripts for each block have been generated in the **Out-of-Context Module Runs** tab (located at the bottom of the Design Runs window).
<br>

<p align="center">
  <img src="after_generate_scripts.png" alt="Out-of-Context Runs" width="800">
</p>
<br>

4. **Adjust Strategy**: Using the default strategy often results in **timing violations**. Therefore, you must change the synthesis/implementation strategy as shown below:
    * **For Vivado 2023.2**:
    <br>
    <img src="Design_Runs_2023.2.png" alt="Design Runs 2023.2" width="800">
    <br><br>

    * **For Vivado 2025.1**:
    <br>
    <img src="Design_Runs_2025.1.png" alt="Design Runs 2025.1" width="800">
    <br>

5. **Launch Runs**: Click **Generate Bitstream** again. This time, select **Launch runs on local host** and click **OK** to proceed with synthesis, implementation, and bitstream generation.
<br>

<p align="center">
  <img src="launch_bitstream.png" alt="Launch Bitstream" width="500">
</p>
<br>

6. **Completion**: Once the bitstream is successfully generated, a completion dialog will appear. (You may click OK to view the implementation results).
<br>

<p align="center">
  <img src="bitstream_sucess.png" alt="Bitstream Success" width="500">
</p>
<br>

7. **Export Hardware**: Navigate to **File > Export > Export Hardware**.
<br>

<p align="center">
  <img src="export_hardware.png" alt="Export Hardware" width="600">
</p>
<br>

8. **Include Bitstream**: Ensure you select **Include bitstream** to package the bitstream within the XSA file.
<br>

<p align="center">
  <img src="include_bitstream.png" alt="Include Bitstream" width="600">
</p>
<br>

9. **Finish**: **Remember the export path** of the XSA file. Click **Finish** and verify that the `.xsa` file has been created in the specified directory.
    * All tasks in Vivado are now complete.
    * Please proceed to the next section: `03_Petalinux`.

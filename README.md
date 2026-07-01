# OpenROAD Flow for Raw RTL-to-GDS Dataset Generation

This repository contains an open RTL-to-GDS flow for generating raw physical design datasets for machine learning research in digital VLSI physical design.

The flow is based on open-source EDA tools and supports multiple open PDKs. It runs logic synthesis, floorplanning, placement, clock tree synthesis, routing, extraction, timing analysis, and report generation. The generated raw data can later be used to build task-specific datasets, such as parasitic capacitance prediction, congestion prediction, timing prediction, DRC prediction, and other ML-for-EDA benchmarks.

## Related Repositories

* Main flow repository:
  https://github.com/NZheludkov/OpenROAD-flow

* RTL design dataset:
  https://github.com/NZheludkov/RTL-Dataset

* Open PDK collection:
  https://github.com/NZheludkov/open_pdk

## Repository Purpose

This repository is intended to generate a raw RTL-to-GDS dataset. It does not directly train ML models and does not extract task-specific features. Instead, it preserves intermediate and final design artifacts from the physical design flow.

Typical generated artifacts include:

```text
config files
synthesis netlists and reports
floorplan DEF/netlist/SDC/SDF/reports
placement DEF/netlist/SDC/SDF/reports
CTS DEF/netlist/SDC/SDF/reports
post-CTS DEF/netlist/SDC/SDF/reports
routed DEF/netlist/SPEF/SDF/reports
OpenROAD metrics
logs
run-level summary files
```

Task-specific datasets should be generated from this raw dataset using separate extractor scripts or repositories.

## Supported PDKs

The flow currently supports the following open PDKs:

```text
ASAP7
FreePDK45
SkyWater130 / Sky130
GF180
```

The PDK is selected automatically from the `--pdk_path` argument. The path should contain one of the following identifiers:

```text
asap7
freepdk45
sky130
gf180
```

Each PDK has its own technology LEF, standard-cell LEF, Liberty file, routing layers, filler cells, tap/endcap cells, CTS buffers, tie cells, extraction rules, and default design parameters.

## Required Tools

The following tools must be installed and available in the system `PATH`:

```text
Yosys
OpenROAD
Tcl
Bash
Git
Python 3
```

Check that the tools are available:

```bash
yosys -V
openroad -version
python3 --version
```

The flow expects OpenROAD to support the commands used in the Tcl scripts under `flow_scripts/`.

## Directory Setup

A typical working directory may look like this:

```text
workdir/
  OpenROAD-flow/
  RTL-Dataset/
  open_pdk/
  raw_dataset_output/
```

Clone the repositories:

```bash
git clone https://github.com/NZheludkov/OpenROAD-flow.git
git clone https://github.com/NZheludkov/RTL-Dataset.git
git clone https://github.com/NZheludkov/open_pdk.git
```

Enter the flow repository:

```bash
cd OpenROAD-flow
```

Make the scripts executable:

```bash
chmod +x run_flow.sh
chmod +x mass_run.sh
```

## RTL Dataset Structure

The flow expects RTL designs and design-specific configuration files from the RTL dataset repository.

Expected structure:

```text
RTL-Dataset/
  designs/
    <design_name>/
      config.tcl
      ...
```

The design-specific `config.tcl` is appended to the generated run configuration. It should define design-level information such as the top module, clock name, RTL files, and other design-specific variables required by the Yosys/OpenROAD scripts.

## PDK Structure

The PDK path should point to one of the supported PDK directories from the open PDK repository.

Example paths:

```text
open_pdk/asap7
open_pdk/freepdk45
open_pdk/sky130
open_pdk/gf180
```

The internal PDK structure should include LEF, Liberty, Yosys technology mapping files, and OpenROAD extraction rules expected by `run_flow.sh`.

## Running a Single Design

Use `run_flow.sh` to run one design with one configuration.

Example:

```bash
./run_flow.sh \
  --pdk_path /path/to/open_pdk/freepdk45 \
  --rtl_dataset_path /path/to/RTL-Dataset \
  --design ac97_top \
  --output_dir /path/to/raw_dataset_output
```

The required arguments are:

```text
--pdk_path
--rtl_dataset_path
--design
--output_dir
```

Optional arguments:

```text
--clk_period
--io_delay
--cu
--ar
--pdn_hwidth_track
--pdn_hspacing_track
--pdn_hpitch_track
--pdn_vwidth_track
--pdn_vspacing_track
--pdn_vpitch_track
--verbose
```

Example with explicit parameters:

```bash
./run_flow.sh \
  --pdk_path /path/to/open_pdk/sky130 \
  --rtl_dataset_path /path/to/RTL-Dataset \
  --design aes_core \
  --output_dir /path/to/raw_dataset_output \
  --clk_period 30.0 \
  --io_delay 0.00 \
  --cu 20 \
  --ar 1.0 \
  --pdn_hwidth_track 4 \
  --pdn_hspacing_track 4 \
  --pdn_hpitch_track 32 \
  --pdn_vwidth_track 4 \
  --pdn_vspacing_track 4 \
  --pdn_vpitch_track 32
```

## Main Flow Parameters

### Clock Period

```text
--clk_period
```

Target clock period used for synthesis and timing constraints.

### IO Delay

```text
--io_delay
```

Input/output delay used in generated constraints.

### Core Utilization

```text
--cu
```

Target core utilization for floorplanning and placement.

### Aspect Ratio

```text
--ar
```

Aspect ratio of the core area.

### PDN Parameters

Horizontal PDN parameters:

```text
--pdn_hwidth_track
--pdn_hspacing_track
--pdn_hpitch_track
```

Vertical PDN parameters:

```text
--pdn_vwidth_track
--pdn_vspacing_track
--pdn_vpitch_track
```

These parameters are expressed in routing tracks and are used to generate different power grid configurations.

## Output Directory Structure

The output directory is organized as:

```text
<output_dir>/
  <pdk_name>/
    <design_name>/
      <run_config_name>/
        config/
        synt/
        floorplan/
        prects/
        cts/
        postcts/
        route/
        log/
        openroad_metrics/
        run_info.csv
```

Example:

```text
raw_dataset_output/
  freepdk45/
    ac97_top/
      CLK_100.0_IO_0.00_CU_20_AR_1.0_HW_4_HS_4_HP_32_VW_4_VS_4_VP_32/
        config/
          config.tcl
        synt/
          constraint.tcl
          ...
        floorplan/
          ...
        prects/
          ...
        cts/
          ...
        postcts/
          ...
        route/
          ...
        log/
          yosys_log.txt
          openroad_logs.txt
        openroad_metrics/
          openroad_metrics
        run_info.csv
```

The run directory name is generated from the design parameters:

```text
CLK_<clock_period>_IO_<io_delay>_CU_<core_util>_AR_<aspect_ratio>_HW_<hwidth>_HS_<hspacing>_HP_<hpitch>_VW_<vwidth>_VS_<vspacing>_VP_<vpitch>
```

## Generated Configuration File

For every run, the flow creates:

```text
config/config.tcl
```

This file stores the resolved PDK configuration, design parameters, technology files, standard-cell library files, routing layers, timing constraints, PDN parameters, and design-specific settings.

This makes each run self-contained and easier to reproduce.

## Running Multiple Designs

Use `mass_run.sh` to run multiple designs and multiple parameter configurations.

Example:

```bash
./mass_run.sh \
  --pdk_path /path/to/open_pdk/freepdk45 \
  --rtl_dataset_path /path/to/RTL-Dataset \
  --output_dir /path/to/raw_dataset_output \
  --designs_file design_list.txt \
  --max_parallel 4
```

Required arguments:

```text
--pdk_path
--rtl_dataset_path
--output_dir
--designs_file
```

Optional arguments:

```text
--max_parallel
--verbose
```

The `--max_parallel` option controls how many `run_flow.sh` jobs are launched simultaneously.

Start with a conservative value, for example:

```bash
--max_parallel 2
```

Increase it only after checking CPU and RAM usage.

## Design List Format

The design list file contains one design per line:

```text
ac97_top
aes_core
spi_top
uart_top
```

A design-specific list of clock periods can also be provided after the design name:

```text
ac97_top 100.0 115.0
aes_core 10.0 11.5
spi_top 30.0 34.5
```

If no clock period is specified for a design, the default clock period list from `mass_run.sh` is used.

Empty lines and lines starting with `#` are ignored.

Example:

```text
# design_name [optional clock periods]
ac97_top 100.0 115.0
aes_core 10.0 11.5
spi_top
uart_top
```

## Parameter Sweep in `mass_run.sh`

The default sweep is defined directly in `mass_run.sh`.

Current sweep dimensions:

```text
core utilization: 20, 30
aspect ratio: 0.5, 1.0
PDN horizontal pitch: 32, 64 tracks
PDN vertical pitch: same as horizontal pitch
```

The clock period can be defined globally in the script or per design through `designs_file`.

To change the sweep, edit the arrays in `mass_run.sh`:

```bash
default_clk_periods=("10.0")
cus=("20" "30")
ars=("0.5" "1.0")
pdn_hpitch_tracks=("32" "64")
```

## Example: Generate Dataset for One PDK

```bash
cd OpenROAD-flow

./mass_run.sh \
  --pdk_path /home/user/open_pdk/freepdk45 \
  --rtl_dataset_path /home/user/RTL-Dataset \
  --output_dir /home/user/raw_dataset \
  --designs_file design_list.txt \
  --max_parallel 4
```

## Example: Generate Dataset for All Supported PDKs

```bash
cd OpenROAD-flow

for pdk in asap7 freepdk45 sky130 gf180; do
  ./mass_run.sh \
    --pdk_path /home/user/open_pdk/$pdk \
    --rtl_dataset_path /home/user/RTL-Dataset \
    --output_dir /home/user/raw_dataset \
    --designs_file design_list.txt \
    --max_parallel 2
done
```

The final output structure will be:

```text
raw_dataset/
  asap7/
  freepdk45/
  sky130/
  gf180/
```

## Logs and Metrics

Each run stores logs in:

```text
log/
```

Typical log files:

```text
yosys_log.txt
openroad_logs.txt
```

OpenROAD metrics are written to:

```text
openroad_metrics/
```

These logs are useful for debugging failed runs and for collecting runtime or QoR information.

## Reproducibility

Each run stores its own generated configuration file:

```text
config/config.tcl
```

This file contains all resolved paths and parameters used by the flow. It is the main file required to restore and inspect a particular design run.

For reproducibility, record the following information when publishing a dataset:

```text
OpenROAD version
Yosys version
PDK repository commit
RTL-Dataset repository commit
OpenROAD-flow repository commit
operating system
number of OpenROAD threads
```

Example:

```bash
openroad -version
yosys -V
git rev-parse HEAD
```

## Troubleshooting

### OpenROAD or Yosys Not Found

Check that both tools are installed and available in `PATH`:

```bash
which openroad
which yosys
```

### Unsupported PDK

If the flow reports an unsupported PDK, check that `--pdk_path` contains one of:

```text
asap7
freepdk45
sky130
gf180
```

### Missing Design Configuration

If the design-specific configuration file is missing, check:

```text
RTL-Dataset/designs/<design_name>/config.tcl
```

The design name passed through `--design` must match the directory name in the RTL dataset.

### Large Parallel Runs Fail

Reduce the number of parallel jobs:

```bash
--max_parallel 1
```

or

```bash
--max_parallel 2
```

OpenROAD runs can consume significant memory, especially during placement, CTS, routing, and extraction.

### A Run Fails During Routing

Routing failures may occur for difficult configurations, high utilization, dense PDN settings, or large designs. Failed runs should be inspected using:

```text
log/openroad_logs.txt
openroad_metrics/
```

## Suggested Dataset Generation Workflow

1. Clone `OpenROAD-flow`, `RTL-Dataset`, and `open_pdk`.
2. Check that `openroad` and `yosys` are installed.
3. Prepare a `design_list.txt`.
4. Run one small design first.
5. Inspect logs and output files.
6. Run `mass_run.sh` for the full design list.
7. Archive the raw output directory.
8. Use separate extractor scripts to build task-specific ML datasets.

## Minimal End-to-End Example

```bash
git clone https://github.com/NZheludkov/OpenROAD-flow.git
git clone https://github.com/NZheludkov/RTL-Dataset.git
git clone https://github.com/NZheludkov/open_pdk.git

cd OpenROAD-flow

chmod +x run_flow.sh
chmod +x mass_run.sh

echo "ac97_top 100.0 115.0" > design_list.txt

./mass_run.sh \
  --pdk_path ../open_pdk/freepdk45 \
  --rtl_dataset_path ../RTL-Dataset \
  --output_dir ../raw_dataset \
  --designs_file design_list.txt \
  --max_parallel 1
```

After completion, the generated raw dataset will be available in:

```text
../raw_dataset/
```

## Notes

* The flow is intended for dataset generation and research experiments.
* The raw dataset can be large; make sure enough disk space is available.
* The current flow targets standard-cell-based digital blocks.
* PDK-specific default parameters are defined in `run_flow.sh`.
* Parameter sweeps are defined in `mass_run.sh`.
* Task-specific labels and features should be extracted in separate scripts or repositories.

## Citation

If you use this flow or the generated dataset in academic work, please cite the corresponding repository and dataset paper when available.

## License

Specify the repository license here.

#!/bin/bash

#DESIGNS
designs="\
ac97_top \
aes_cipher_top \
aes_core \
aes128_core \
AltOR32 \
BRSFmnCE \
des3 \
dmx_tx \
dynamic_node_top_wrap \
eth_top \
fht \
FIR_filter \
fpu \
gfx_top \
gng \
i2c_master_top \
idft_top \
IIR_filter \
ima_adpcm_dec \
ima_adpcm_enc \
jpeg_encoder \
keccak \
lfsr \
mc_top \
MC6803_gen2 \
Md5Core \
MIPS32_Processor \
or1200_top_cm4_top \
pci_bridge32 \
pcm_slv_top \
picosoc \
point_scalar_mult \
RS_dec \
rvx \
sasc_top \
sdrc_top \
sha256 \
simple_spi_top \
spi_top \
spiMaster \
streamScaler \
trigonometric \
tv80s \
uart_top \
usb_phy \
USFFT64_2B \
vga_enh_top \
wb_dma_top \
wbqspiflash \
xge_mac \
xtea \
"

#PDK PATH
pdk_path="/home/nvgel/phd/open_pdk/lambdapdk/freepdk45"

#RTL PATH
rtl_path="/home/nvgel/phd/RTL-Dataset"

#OUT DIR
out_dir="/home/nvgel/phd/runs"

#run flow for choosen designs
for design in $designs
do
    echo "Processing: $design"
    export design
    ./run_flow_v2.sh --pdk_path $pdk_path  --rtl_dataset_path $rtl_path  --design $design --output_dir $out_dir 
done

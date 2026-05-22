#!/bin/bash

#source env for run openroad
#. $HOME/OpenROAD-flow-scripts/env.sh

#choose designs for run
#usb_phy +
#pcm_slv_top + 
#FIR_filter + 
#simple_spi_top +
#sasc_top +
#i2c_master_top +
#ac97_top +
#mc_top +
#sha256 +
#trigonometric +
#des3 +
#aes128_core -
#aes_cipher_top -
#aes_core +
#dynamic_node_top_wrap +
#eth_top -
#spi_top +
#Md5Core +

#WORK
designs="\
ac97_top \
aes_core \
des3 \
dynamic_node_top_wrap \
FIR_filter \
i2c_master_top \
mc_top \
Md5Core \
pcm_slv_top \
picosoc \
sasc_top \
sha256 \
simple_spi_top \
spi_top \
trigonometric \
tv80s \
usb_phy
wb_dma_top \
IIR_filter \
jpeg_encoder \
idft_top \
gng \
fht \
wbqspiflash \
point_scalar_mult \
keccak \
xge_mac \
RS_dec \
spiMaster \
uart_top \
dmx_tx \
pci_bridge32 \
xtea \
USFFT64_2B \
MC6803_gen2 \
MIPS32_Processor \
aes128_core \
aes_cipher_top \
sdrc_top \
ima_adpcm_dec \
ima_adpcm_enc \
BRSFmnCE \
vga_enh_top \
"

#PDK PATH
pdk_path="/home/nzheludkov/phd/lambdapdk/lambdapdk/freepdk45"

#RTL PATH
rtl_path="/home/nzheludkov/phd/RTL-Dataset"

#OUT DIR
out_dir="/home/nzheludkov/phd/runs"

#run flow for choosen designs
for design in $designs
do
    echo "Processing: $design"
    export design
    ./run_flow.sh --pdk_path $pdk_path  --rtl_dataset_path $rtl_path  --design $design --output_dir $out_dir 
done

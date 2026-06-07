#!/bin/bash

# Значения по умолчанию
pdk_path=""
rtl_dataset_path=""
design=""
output_dir=""
verbose=0

# Flow params (empty => use PDK defaults)
CLK_PERIOD=""
IO_DELAY=""
CU=""
AR=""

PDN_HWIDTH_TRACK=""
PDN_HSPACING_TRACK=""
PDN_HPITCH_TRACK=""

PDN_VWIDTH_TRACK=""
PDN_VSPACING_TRACK=""
PDN_VPITCH_TRACK=""

# Функция для вывода справки
show_help() {
    cat << EOF
Использование: $0 [ОПЦИИ]

Обязательные опции:
    --pdk_path PATH         Путь к PDK
    --rtl_dataset_path PATH Путь к RTL датасету

Дополнительные опции:
    --output_dir PATH       Директория для результатов (по умолчанию: ./output)
    --verbose, -v           Подробный вывод
    --help, -h              Показать эту справку

Пример:
    $0 --pdk_path ./PDK --rtl_dataset_path ./data/dataset
EOF
}

# Парсинг аргументов командной строки
while [[ $# -gt 0 ]]; do
    case $1 in
        --pdk_path)
            pdk_path="$2"
            shift 2
            ;;
        --rtl_dataset_path)
            rtl_dataset_path="$2"
            shift 2
            ;;
         --design)
            design="$2"
            shift 2
            ;;           
        --output_dir)
            output_dir="$2"
            shift 2
            ;;
        --verbose|-v)
            verbose=1
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        --clk_period)
            CLK_PERIOD="$2"
            shift 2
            ;;

        --io_delay)
            IO_DELAY="$2"
            shift 2
            ;;

        --cu)
            CU="$2"
            shift 2
            ;;

        --ar)
            AR="$2"
            shift 2
            ;;

        --pdn_hwidth_track)
            PDN_HWIDTH_TRACK="$2"
            shift 2
            ;;

        --pdn_hspacing_track)
            PDN_HSPACING_TRACK="$2"
            shift 2
            ;;

        --pdn_hpitch_track)
            PDN_HPITCH_TRACK="$2"
            shift 2
            ;;

        --pdn_vwidth_track)
            PDN_VWIDTH_TRACK="$2"
            shift 2
            ;;

        --pdn_vspacing_track)
            PDN_VSPACING_TRACK="$2"
            shift 2
            ;;

        --pdn_vpitch_track)
            PDN_VPITCH_TRACK="$2"
            shift 2
            ;;
        *)
            echo "Ошибка: Неизвестная опция $1"
            echo "Используйте --help для получения справки"
            exit 1
            ;;
    esac
done

# Проверка обязательных параметров
if [[ -z "$pdk_path" ]]; then
    echo "Ошибка: Не указан параметр --pdk_path"
    echo "Используйте --help для получения справки"
    exit 1
fi

if [[ -z "$rtl_dataset_path" ]]; then
    echo "Ошибка: Не указан параметр --rtl_dataset_path"
    echo "Используйте --help для получения справки"
    exit 1
fi

if [[ -z "$design" ]]; then
    echo "Ошибка: Не указан параметр --design"
    echo "Используйте --help для получения справки"
    exit 1
fi

if [[ -z "$output_dir" ]]; then
    echo "Ошибка: Не указан параметр --output_dir"
    echo "Используйте --help для получения справки"
    exit 1
fi

# Создание выходной директории
#mkdir -p "$output_dir"

# Вывод информации (если verbose режим)
if [[ $verbose -eq 1 ]]; then
    echo "=== Параметры запуска ==="
    echo "PDK путь: $pdk_path"
    echo "RTL датасет: $rtl_dataset_path"
    echo "Выходная директория: $output_dir"
    echo "========================"
fi


# =========================
# PDK configuration
# =========================

if [[ "$pdk_path" =~ freepdk45 ]]; then

    tech_lef="${pdk_path}/base/apr/freepdk45.tech.lef"
    cells_lef="${pdk_path}/libs/nangate45/lef/NangateOpenCellLibrary.macro.mod.lef"
    lef_list="${tech_lef} ${cells_lef}"

    liberty="${pdk_path}/libs/nangate45/nldm/NangateOpenCellLibrary_typical.lib"

    core_site="FreePDK45_38x28_10R_NP_162NW_34O"

    tap_cell="TAPCELL_X1"
    endcap_cell="TAPCELL_X1"
    tap_cell_distance="120"

    techmap_verilog_files=$(echo ${pdk_path}/libs/nangate45/techmap/yosys/*)

    bottom_routing_metal="metal1"
    top_routing_metal="metal7"

    pins_hor_layers="metal3 metal5"
    pins_ver_layers="metal2 metal4"

    wire_rc_metal="metal3"

    tiehi_cell="LOGIC1_X1"
    tielo_cell="LOGIC0_X1"

    tiehi_cell_pin="Z"
    tielo_cell_pin="Z"

    filler_cells="FILLCELL_X1 FILLCELL_X2 FILLCELL_X4 FILLCELL_X8 FILLCELL_X16 FILLCELL_X32"

    dont_use_cells="ANTENNA_X1 FILL* LOGIC* TBUF* TINV* TLAT*"

    max_slew_cts="0.5"
    max_cap_cts="0.3"

    cts_root_buf="CLKBUF_X3"
    cts_buf_list="CLKBUF_X1 CLKBUF_X2 CLKBUF_X3"

    delay_constraint_synt="100" ## ps
    driving_cell="BUF_X2"
    output_load_synt="100" ## fF

    process_node="45"

    liberty_time_unit="ns"
    liberty_current_unit="mA"
    liberty_voltage_unit="V"
    liberty_res_unit="kohm"
    liberty_cap_unit="fF"

    ndr_type="full"

    rc_extract_file="${pdk_path}/base/pex/openroad/typical.rules"

    pdk_name="freepdk45"

    #SDC VARS
    MAX_TRANSITION="0.2"
    MAX_FANOUT="16"
    OUT_PORT_LOAD="0.1"
    INPUT_TRANSITION="0.2"

    # =========================
    # Default flow parameters
    # =========================

    : ${CLK_PERIOD:=100.0}
    : ${IO_DELAY:=0.00}
    : ${CU:=20}
    : ${AR:=1.0}

    : ${PDN_HWIDTH_TRACK:=4}
    : ${PDN_HSPACING_TRACK:=4}
    : ${PDN_HPITCH_TRACK:=32}

    : ${PDN_VWIDTH_TRACK:=4}
    : ${PDN_VSPACING_TRACK:=4}
    : ${PDN_VPITCH_TRACK:=32}

elif [[ "$pdk_path" =~ asap7 ]]; then

    tech_lef="${pdk_path}/base/apr/asap7_tech.lef"
    cells_lef="${pdk_path}/libs/asap7sc7p5t_lvt/lef/asap7sc7p5t_28_L.lef"
    lef_list="${tech_lef} ${cells_lef}"

    liberty="${pdk_path}/libs/asap7sc7p5t_lvt/nldm/asap7_merge_lib_ss_lvt.lib"

    core_site="asap7sc7p5t"

    tap_cell="TAPCELL_ASAP7_75t_L"
    endcap_cell="TAPCELL_ASAP7_75t_L"

    tap_cell_distance="25"

    techmap_verilog_files=$(echo ${pdk_path}/libs/asap7sc7p5t_lvt/techmap/yosys/*)

    bottom_routing_metal="M1"
    top_routing_metal="M7"

    pins_hor_layers="M2 M4"
    pins_ver_layers="M3 M5"

    wire_rc_metal="M5"

    tiehi_cell="TIEHIx1_ASAP7_75t_L"
    tielo_cell="TIELOx1_ASAP7_75t_L"

    tiehi_cell_pin="H"
    tielo_cell_pin="L"

    filler_cells="DECAPx10_ASAP7_75t_L \
    DECAPx1_ASAP7_75t_L \
    DECAPx2_ASAP7_75t_L \
    DECAPx2b_ASAP7_75t_L \
    DECAPx4_ASAP7_75t_L \
    DECAPx6_ASAP7_75t_L \
    FILLER_ASAP7_75t_L \
    FILLERxp5_ASAP7_75t_L \
    "

    dont_use_cells="CK* TAP* TIE*"

    max_slew_cts="0.3"
    max_cap_cts="0.1"

    cts_root_buf="CKINVDCx16_ASAP7_75t_L"

    cts_buf_list="CKINVDCx16_ASAP7_75t_L \
    CKINVDCx8_ASAP7_75t_L \
    CKINVDCx12_ASAP7_75t_L \
    CKINVDCx10_ASAP7_75t_L \
    "

    delay_constraint_synt="50" ## ps
    driving_cell="BUFx2_ASAP7_75t_L"
    output_load_synt="100" ## fF

    process_node="7"

    liberty_time_unit="ps"
    liberty_current_unit="mA"
    liberty_voltage_unit="V"
    liberty_res_unit="kohm"
    liberty_cap_unit="fF"

    ndr_type="full"

    rc_extract_file="${pdk_path}/base/pex/openroad/typical.rules"

    pdk_name="asap7"

    #SDC VARS
    MAX_TRANSITION="320"
    MAX_FANOUT="16"
    OUT_PORT_LOAD="100"
    INPUT_TRANSITION="320"

    # =========================
    # Default flow parameters
    # =========================

    : ${CLK_PERIOD:=1000.0}
    : ${IO_DELAY:=0.00}
    : ${CU:=30}
    : ${AR:=1.0}

    : ${PDN_HWIDTH_TRACK:=4}
    : ${PDN_HSPACING_TRACK:=4}
    : ${PDN_HPITCH_TRACK:=32}

    : ${PDN_VWIDTH_TRACK:=4}
    : ${PDN_VSPACING_TRACK:=4}
    : ${PDN_VPITCH_TRACK:=32}

elif [[ "$pdk_path" =~ sky130 ]]; then

    tech_lef="${pdk_path}/base/apr/sky130_fd_sc.tlef"
    cells_lef="${pdk_path}/libs/sky130hd/lef/sky130_fd_sc_hd_merged.lef"
    lef_list="${tech_lef} ${cells_lef}"

    liberty="${pdk_path}/libs/sky130hd/nldm/sky130_fd_sc_hd__ss_n40C_1v40.lib.gz"

    core_site="unithd"

    tap_cell="sky130_fd_sc_hd__tapvpwrvgnd_1"
    endcap_cell="sky130_fd_sc_hd__fill_2"

    tap_cell_distance="14"

    techmap_verilog_files=$(echo ${pdk_path}/libs/sky130hd/techmap/yosys/*)

    bottom_routing_metal="met1"
    top_routing_metal="met5"

    pins_hor_layers="met3 met5"
    pins_ver_layers="met2 met4"

    wire_rc_metal="met3"

    tiehi_cell="sky130_fd_sc_hd__conb_1"
    tielo_cell="sky130_fd_sc_hd__conb_1"

    tiehi_cell_pin="HI"
    tielo_cell_pin="LO"

    filler_cells="\
    sky130_fd_sc_hd__decap_12 \
    sky130_fd_sc_hd__decap_4 \
    sky130_fd_sc_hd__decap_3 \
    sky130_fd_sc_hd__decap_6 \
    sky130_fd_sc_hd__decap_8 \
    sky130_fd_sc_hd__fill_8 \
    sky130_fd_sc_hd__fill_4 \
    sky130_fd_sc_hd__fill_2 \
    sky130_fd_sc_hd__fill_1 \
    "

    dont_use_cells="*probe* *tap* *iso* *lpflow* *dly* *clkdly*"

    max_slew_cts="0.5"
    max_cap_cts="0.3"

    cts_root_buf="sky130_fd_sc_hd__clkinv_16"

    cts_buf_list="\
    sky130_fd_sc_hd__clkinv_16 \
    sky130_fd_sc_hd__clkinv_8 \
    sky130_fd_sc_hd__clkinv_4 \
    sky130_fd_sc_hd__clkinv_2 \
    "

    delay_constraint_synt="100" ## ps
    driving_cell="sky130_fd_sc_hd__buf_2"
    output_load_synt="100" ## fF

    process_node="130"

    liberty_time_unit="ns"
    liberty_current_unit="mA"
    liberty_voltage_unit="V"
    liberty_res_unit="kohm"
    liberty_cap_unit="pF"

    ndr_type="full"

    rc_extract_file="${pdk_path}/base/pex/openroad/maximum.rules"

    pdk_name="sky130"

    #SDC VARS
    MAX_TRANSITION="2.0"
    MAX_FANOUT="16"
    OUT_PORT_LOAD="0.1"
    INPUT_TRANSITION="1.0"


    # =========================
    # Default flow parameters
    # =========================

    : ${CLK_PERIOD:=30.0}
    : ${IO_DELAY:=0.00}
    : ${CU:=20}
    : ${AR:=1.0}

    : ${PDN_HWIDTH_TRACK:=4}
    : ${PDN_HSPACING_TRACK:=4}
    : ${PDN_HPITCH_TRACK:=32}

    : ${PDN_VWIDTH_TRACK:=4}
    : ${PDN_VSPACING_TRACK:=4}
    : ${PDN_VPITCH_TRACK:=32}

elif [[ "$pdk_path" =~ gf180 ]]; then

    tech_lef="${pdk_path}/base/apr/gf180mcu_6LM_1TM_9K_9t_tech.lef"
    cells_lef="${pdk_path}/libs/gf180mcu_fd_sc_mcu9t5v0/lef/gf180mcu_fd_sc_mcu9t5v0.lef"
    lef_list="${tech_lef} ${cells_lef}"

    liberty="${pdk_path}/libs/gf180mcu_fd_sc_mcu9t5v0/nldm/gf180mcu_fd_sc_mcu9t5v0__ss_125C_4v50.lib.gz"

    core_site="GF018hv5v_green_sc9"

    tap_cell="gf180mcu_fd_sc_mcu9t5v0__filltie"
    endcap_cell="gf180mcu_fd_sc_mcu9t5v0__endcap"

    tap_cell_distance="25"

    techmap_verilog_files=$(echo ${pdk_path}/libs/gf180mcu_fd_sc_mcu9t5v0/techmap/yosys/*)

    bottom_routing_metal="Metal1"
    top_routing_metal="MetalTop"

    pins_hor_layers="Metal3 Metal5"
    pins_ver_layers="Metal2 Metal4"

    wire_rc_metal="Metal3"

    tiehi_cell="gf180mcu_fd_sc_mcu9t5v0__tieh"
    tielo_cell="gf180mcu_fd_sc_mcu9t5v0__tiel"

    tiehi_cell_pin="Z"
    tielo_cell_pin="ZN"

    filler_cells="gf180mcu_fd_sc_mcu9t5v0__fillcap_64 \
    gf180mcu_fd_sc_mcu9t5v0__fillcap_32 \
    gf180mcu_fd_sc_mcu9t5v0__fillcap_16 \
    gf180mcu_fd_sc_mcu9t5v0__fillcap_8 \
    gf180mcu_fd_sc_mcu9t5v0__fillcap_4 \
    gf180mcu_fd_sc_mcu9t5v0__fill_1 \
    gf180mcu_fd_sc_mcu9t5v0__fill_2"

    dont_use_cells="gf180mcu_fd_sc_mcu9t5v0__antenna \
    gf180mcu_fd_sc_mcu9t5v0__clk* \
    gf180mcu_fd_sc_mcu9t5v0__endcap \
    gf180mcu_fd_sc_mcu9t5v0__fill* \
    gf180mcu_fd_sc_mcu9t5v0__lat* \
    gf180mcu_fd_sc_mcu9t5v0__tie*"

    max_slew_cts="0.5"
    max_cap_cts="0.3"

    cts_root_buf="gf180mcu_fd_sc_mcu9t5v0__clkinv_16"

    cts_buf_list="gf180mcu_fd_sc_mcu9t5v0__clkinv_1 \
    gf180mcu_fd_sc_mcu9t5v0__clkinv_2 \
    gf180mcu_fd_sc_mcu9t5v0__clkinv_4 \
    gf180mcu_fd_sc_mcu9t5v0__clkinv_8 \
    gf180mcu_fd_sc_mcu9t5v0__clkinv_16"

    delay_constraint_synt="100" ## ps
    driving_cell="gf180mcu_fd_sc_mcu9t5v0__buf_2"
    output_load_synt="100" ## fF

    process_node="180"

    liberty_time_unit="ns"
    liberty_current_unit="mA"
    liberty_voltage_unit="V"
    liberty_res_unit="ohm"
    liberty_cap_unit="pF"

    ndr_type="full"

    rc_extract_file="${pdk_path}/base/pex/openroad/gf180mcu_1p6m_1tm_9k_sp_smim_OPTB_wst.rules"

    pdk_name="gf180"

    #SDC VARS
    MAX_TRANSITION="1.0"
    MAX_FANOUT="16"
    OUT_PORT_LOAD="0.1"
    INPUT_TRANSITION="1.0"

    # =========================
    # Default flow parameters
    # =========================

    : ${CLK_PERIOD:=100.0}
    : ${IO_DELAY:=0.00}
    : ${CU:=20}
    : ${AR:=1.0}

    : ${PDN_HWIDTH_TRACK:=4}
    : ${PDN_HSPACING_TRACK:=4}
    : ${PDN_HPITCH_TRACK:=32}

    : ${PDN_VWIDTH_TRACK:=4}
    : ${PDN_VSPACING_TRACK:=4}
    : ${PDN_VPITCH_TRACK:=32}

else
    echo "ERROR: Unsupported PDK: $pdk_path"
    exit 1
fi

# =========================
# Формирование имени подпапки и создание полной директории запуска
# =========================
folder_name=""

if [ -n "$CLK_PERIOD" ]; then
    folder_name+="CLK_${CLK_PERIOD}_"
fi
if [ -n "$IO_DELAY" ]; then
    folder_name+="IO_${IO_DELAY}_"
fi
if [ -n "$CU" ]; then
    folder_name+="CU_${CU}_"
fi
if [ -n "$AR" ]; then
    folder_name+="AR_${AR}_"
fi
if [ -n "$PDN_HWIDTH_TRACK" ]; then
    folder_name+="HW_${PDN_HWIDTH_TRACK}_"
fi
if [ -n "$PDN_HSPACING_TRACK" ]; then
    folder_name+="HS_${PDN_HSPACING_TRACK}_"
fi
if [ -n "$PDN_HPITCH_TRACK" ]; then
    folder_name+="HP_${PDN_HPITCH_TRACK}_"
fi
if [ -n "$PDN_VWIDTH_TRACK" ]; then
    folder_name+="VW_${PDN_VWIDTH_TRACK}_"
fi
if [ -n "$PDN_VSPACING_TRACK" ]; then
    folder_name+="VS_${PDN_VSPACING_TRACK}_"
fi
if [ -n "$PDN_VPITCH_TRACK" ]; then
    folder_name+="VP_${PDN_VPITCH_TRACK}_"
fi

# Удаляем последний символ "_"
folder_name="${folder_name%_}"

# Полный путь: output_dir / pdk_name / design / folder_name
run_dir="${output_dir}/${pdk_name}/${design}/${folder_name}"

# Создаем директорию
mkdir -p "$run_dir/config/"

$rtl_dataset_path/$design/config.tcl

#create constraint file for abc/yosys
mkdir -p "$run_dir/synt/"
constraint_file="$run_dir/synt/constraint.tcl"
cat > "$constraint_file" << EOF
set_driving_cell $driving_cell
set_load $output_load_synt
EOF

#write vars to config.tcl
cat > "$run_dir/config/config.tcl" << EOF
set run_dir "$run_dir"
set pdk_path "$pdk_path"
set rtl_dataset_path "$rtl_dataset_path"
set design "$design"
set output_dir "$output_dir"
set pdk_name "$pdk_name"
set tech_lef "$tech_lef"
set cells_lef "$cells_lef"
set lef_list [concat \$tech_lef \$cells_lef]
set liberty "$liberty"
set core_site "$core_site"
set tap_cell "$tap_cell"
set endcap_cell "$endcap_cell"
set tap_cell_distance "$tap_cell_distance"
set techmap_verilog_files "$techmap_verilog_files"
set bottom_routing_metal "$bottom_routing_metal"
set top_routing_metal "$top_routing_metal"
set pins_hor_layers [list $pins_hor_layers]
set pins_ver_layers [list $pins_ver_layers]
set wire_rc_metal "$wire_rc_metal"
set tiehi_cell "$tiehi_cell"
set tielo_cell "$tielo_cell"
set tiehi_cell_pin "$tiehi_cell_pin"
set tielo_cell_pin "$tielo_cell_pin"
set filler_cells [list $filler_cells]
set dont_use_cells [list $dont_use_cells]
set max_slew_cts "$max_slew_cts"
set max_cap_cts "$max_cap_cts"
set cts_root_buf "$cts_root_buf"
set cts_buf_list [list $cts_buf_list]
set process_node "$process_node"
set rc_extract_file "$rc_extract_file"
set CLK_PERIOD "$CLK_PERIOD"
set IO_DELAY "$IO_DELAY"
set CU "$CU"
set AR "$AR"
set PDN_HWIDTH_TRACK "$PDN_HWIDTH_TRACK"
set PDN_HSPACING_TRACK "$PDN_HSPACING_TRACK"
set PDN_HPITCH_TRACK "$PDN_HPITCH_TRACK"
set PDN_VWIDTH_TRACK "$PDN_VWIDTH_TRACK"
set PDN_VSPACING_TRACK "$PDN_VSPACING_TRACK"
set PDN_VPITCH_TRACK "$PDN_VPITCH_TRACK"
set MAX_TRANSITION "$MAX_TRANSITION"
set MAX_FANOUT "$MAX_FANOUT"
set OUT_PORT_LOAD "$OUT_PORT_LOAD"
set INPUT_TRANSITION "$INPUT_TRANSITION"
set liberty_time_unit "$liberty_time_unit"
set liberty_current_unit "$liberty_current_unit"
set liberty_voltage_unit "$liberty_voltage_unit"
set liberty_res_unit "$liberty_res_unit"
set liberty_cap_unit "$liberty_cap_unit"
set ndr_type "$ndr_type"
set driving_cell "$driving_cell"
set delay_constraint_synt "$delay_constraint_synt"
set output_load_synt "$output_load_synt"
set constraint_file "$constraint_file"
EOF

#source design specific config
design_config="${rtl_dataset_path}/designs/${design}/config.tcl"

if [[ -f "$design_config" ]]; then
    echo "" >> "$run_dir/config/config.tcl"                  # пустая строка для читаемости
    echo "# Design-specific settings" >> "$run_dir/config/config.tcl"
    cat "$design_config" >> "$run_dir/config/config.tcl"
    echo "Добавлен дизайн-конфиг из $design_config"
else
    echo "Предупреждение: файл $design_config не найден, пропускаем."
fi

#export config file
export CONFIG_FILE="$run_dir/config/config.tcl"

#create dir for yosys log
mkdir -p "$run_dir/log/"

#run synt in yosys
SECONDS=0
yosys ./flow_scripts/run_yosys.tcl -l "$run_dir/log/yosys_log.txt"
yosys_time=$SECONDS; export yosys_time

#create dir for openroad log
mkdir -p "$run_dir/log/"

#create dir for openroad metrics
mkdir -p "$run_dir/openroad_metrics/"

#run topo in openroad

#openroad -threads 4 ./flow_scripts/run_openroad.tcl -log "$run_dir/log/openroad_logs.txt" -metrics "$run_dir/openroad_metrics/openroad_metrics" -exit

#exit 0
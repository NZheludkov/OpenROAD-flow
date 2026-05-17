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

PDN_HWIDTH=""
PDN_HSPACING=""
PDN_HPITCH=""

PDN_VWIDTH=""
PDN_VSPACING=""
PDN_VPITCH=""

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

        --pdn_hwidth)
            PDN_HWIDTH="$2"
            shift 2
            ;;

        --pdn_hspacing)
            PDN_HSPACING="$2"
            shift 2
            ;;

        --pdn_hpitch)
            PDN_HPITCH="$2"
            shift 2
            ;;

        --pdn_vwidth)
            PDN_VWIDTH="$2"
            shift 2
            ;;

        --pdn_vspacing)
            PDN_VSPACING="$2"
            shift 2
            ;;

        --pdn_vpitch)
            PDN_VPITCH="$2"
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
    top_routing_metal="metal10"

    pins_hor_layers="metal3 metal5"
    pins_ver_layers="metal2 metal4"

    wire_rc_metal="metal3"

    tiehi_cell="LOGIC1_X1"
    tielo_cell="LOGIC0_X1"

    tiehi_cell_pin="Z"
    tielo_cell_pin="Z"

    filler_cells="FILLCELL_X1 FILLCELL_X2 FILLCELL_X4 FILLCELL_X8 FILLCELL_X16 FILLCELL_X32"

    dont_use_cells="ANTENNA_X1 FILL* LOGIC* TAPCELL_X1 TBUF* TINV* TLAT*"

    max_slew_cts="0.5"
    max_cap_cts="0.3"

    cts_root_buf="CLKBUF_X3"
    cts_buf_list="CLKBUF_X1 CLKBUF_X2 CLKBUF_X3"

    process_node="45"

    rc_extract_file="${pdk_path}/base/pex/openroad/typical.rules"

    pdk_name="freepdk45"
    echo aaaa

    # =========================
    # Default flow parameters
    # =========================

    : ${CLK_PERIOD:=100.0}
    : ${IO_DELAY:=0.33}
    : ${CU:=20}
    : ${AR:=1.0}

    : ${PDN_HWIDTH:=1.6}
    : ${PDN_HSPACING:=1.6}
    : ${PDN_HPITCH:=16}

    : ${PDN_VWIDTH:=1.6}
    : ${PDN_VSPACING:=1.6}
    : ${PDN_VPITCH:=16}

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

    process_node="180"

    rc_extract_file="${pdk_path}/base/pex/openroad/gf180mcu_1p6m_1tm_9k_sp_smim_OPTB_wst.rules"

    pdk_name="gf180"

    # =========================
    # Default flow parameters
    # =========================

    : ${CLK_PERIOD:=100.0}
    : ${IO_DELAY:=0.33}
    : ${CU:=20}
    : ${AR:=1.0}

    : ${PDN_HWIDTH:=4.4}
    : ${PDN_HSPACING:=4.4}
    : ${PDN_HPITCH:=44}

    : ${PDN_VWIDTH:=4.4}
    : ${PDN_VSPACING:=4.4}
    : ${PDN_VPITCH:=44}

else
    echo "ERROR: Unsupported PDK: $pdk_path"
    exit 1
fi

# =========================
# Export all variables
# =========================

export pdk_path
export rtl_dataset_path
export design
export output_dir
export verbose

export tech_lef
export cells_lef
export lef_list
export liberty

export core_site

export tap_cell
export endcap_cell
export tap_cell_distance

export techmap_verilog_files

export bottom_routing_metal
export top_routing_metal

export pins_hor_layers
export pins_ver_layers

export wire_rc_metal

export tiehi_cell
export tielo_cell

export tiehi_cell_pin
export tielo_cell_pin

export filler_cells
export dont_use_cells

export max_slew_cts
export max_cap_cts

export cts_root_buf
export cts_buf_list

export process_node

export rc_extract_file

export pdk_name

export CLK_PERIOD
export IO_DELAY
export CU
export AR

export PDN_HWIDTH
export PDN_HSPACING
export PDN_HPITCH

export PDN_VWIDTH
export PDN_VSPACING
export PDN_VPITCH

#run synt in yosys
yosys ./flow_scripts/run_yosys.tcl

#run topo in openroad
openroad -threads 4 ./flow_scripts/run_openroad.tcl -exit

exit 0
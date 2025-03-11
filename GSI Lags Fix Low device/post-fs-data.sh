#!/system/bin/sh

# CPU - Força governador performance
CPU_DIR="/sys/devices/system/cpu"
if [ -d "$CPU_DIR" ]; then
    for cpu in $CPU_DIR/cpu[0-9]*; do
        if [ -f "$cpu/cpufreq/scaling_governor" ]; then
            echo "performance" > "$cpu/cpufreq/scaling_governor"
        fi
    done
fi

# GPU - Força performance
if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
    echo "performance" > /sys/class/kgsl/kgsl-3d0/devfreq/governor
    echo "0" > /sys/class/kgsl/kgsl-3d0/devfreq/adreno_min_pwrlevel
    echo "0" > /sys/class/kgsl/kgsl-3d0/devfreq/adreno_max_pwrlevel
fi

if [ -d "/sys/devices/platform/mali.0" ]; then
    echo "performance" > /sys/devices/platform/mali.0/devfreq/governor
fi

# I/O - Ajustes no agendador
if [ -f "/sys/block/mmcblk0/queue/scheduler" ]; then
    echo "deadline" > /sys/block/mmcblk0/queue/scheduler
fi
if [ -f "/sys/block/mmcblk0/queue/read_ahead_kb" ]; then
    echo "2048" > /sys/block/mmcblk0/queue/read_ahead_kb
fi

# Melhorar gerenciamento de memória para aplicativos
echo "0" > /proc/sys/vm/oom_kill_allocating_task
echo "1" > /proc/sys/vm/overcommit_memory
echo "100" > /proc/sys/vm/overcommit_ratio
echo "1" > /proc/sys/vm/panic_on_oom

# Priorizar processos de aplicativos
setprop ro.vendor.qti.sys.fw.bservice_enable true
setprop ro.vendor.qti.sys.fw.bservice_limit 5
setprop ro.vendor.qti.sys.fw.bservice_age 5000

# Ajustes de I/O para melhorar a leitura de dados
for block in /sys/block/*/queue; do
    echo "256" > "$block/nr_requests"
    echo "1024" > "$block/read_ahead_kb"
    echo "deadline" > "$block/scheduler"
done

# Otimização de renderização e UI
setprop debug.sf.latch_unsignaled 1
setprop debug.sf.early_phase_offset_ns 500000
setprop debug.sf.early_app_phase_offset_ns 500000
setprop debug.sf.early_gl_phase_offset_ns 3000000
setprop debug.sf.early_gl_app_phase_offset_ns 15000000
setprop debug.sf.high_fps_early_phase_offset_ns 6100000
setprop debug.sf.high_fps_early_gl_phase_offset_ns 9000000
setprop debug.sf.high_fps_late_app_phase_offset_ns 1000000
setprop debug.sf.hw 1
setprop debug.sf.enable_hwc_vds 1
setprop persist.sys.ui.hw true
setprop ro.surface_flinger.max_frame_latency 1

# Desativar verificações desnecessárias
setprop ro.config.hw_quickpoweron true
setprop ro.config.hw_fast_dormancy 1
setprop ro.config.hw_power_saving false

# Priorizar aplicativos em primeiro plano
setprop ro.vendor.qti.sys.fw.bg_apps_limit 32
setprop ro.vendor.qti.sys.fw.bg_cached_ratio 0.33
setprop ro.vendor.qti.sys.fw.bg_empty_app_limit 8

# Desativar animações desnecessárias
setprop debug.sf.disable_backpressure 1
setprop debug.sf.no_hw_vsync 1
setprop persist.sys.force_sw_gles 0

# Limpeza de cache e memória
sync
echo 3 > /proc/sys/vm/drop_caches

# Ajustes de rede
setprop net.tcp.buffersize.default 4096,87380,256960,4096,16384,256960
setprop net.tcp.buffersize.wifi 4096,87380,256960,4096,16384,256960
setprop net.tcp.buffersize.umts 4096,87380,256960,4096,16384,256960
setprop net.tcp.buffersize.gprs 4096,87380,256960,4096,16384,256960
setprop net.tcp.buffersize.edge 4096,87380,256960,4096,16384,256960

# Ajustes de termal
setprop vendor.thermal.enable false
setprop vendor.thermal.engine 0

# Ajustes de prioridade de threads
setprop ro.vendor.qti.sys.fw.use_trim_settings true
setprop ro.vendor.qti.sys.fw.trim_empty_percent 50
setprop ro.vendor.qti.sys.fw.trim_cache_percent 100
setprop ro.vendor.qti.sys.fw.trim_enable_memory 1

# RAM & ZRAM
echo "lz4hc" > /sys/block/zram0/comp_algorithm
echo "200" > /proc/sys/vm/swappiness
echo "10" > /proc/sys/vm/page-cluster
echo "1" > /sys/kernel/mm/swap/vma_ra_enabled

# UI & Renderização
setprop debug.hwui.renderer backend gl
setprop persist.sys.sf.native_mode 1

# Ajustes de desempenho geral
setprop ro.config.low_ram true
setprop persist.sys.scrollingcache 0
setprop ro.HOME_APP_ADJ 0
setprop video.accelerate.hw 1
setprop debug.qctwa.statusbar 1

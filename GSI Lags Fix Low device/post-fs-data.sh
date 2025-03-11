#!/system/bin/sh

# CPU Dinâmica - Detecção automática e ajuste para qualquer governor
CPU_DIR="/sys/devices/system/cpu"

if [ -d "$CPU_DIR" ]; then
    for cpu in $CPU_DIR/cpu[0-9]*; do
        if [ -f "$cpu/cpufreq/scaling_governor" ]; then
            # Detecta o governor atual
            CURRENT_GOV=$(cat "$cpu/cpufreq/scaling_governor")
            
            # Reaplica o governor detectado
            echo "$CURRENT_GOV" > "$cpu/cpufreq/scaling_governor"
            
            # Ajustes específicos para cada governor
            case "$CURRENT_GOV" in
                schedutil)
                    echo "200" > "$cpu/cpufreq/schedutil/up_rate_limit_us"
                    echo "1000" > "$cpu/cpufreq/schedutil/down_rate_limit_us"
                    ;;
                interactive)
                    echo "80" > "$cpu/cpufreq/interactive/boostpulse_duration"
                    echo "20000" > "$cpu/cpufreq/interactive/min_sample_time"
                    echo "95" > "$cpu/cpufreq/interactive/go_hispeed_load"
                    echo "1" > "$cpu/cpufreq/interactive/io_is_busy"
                    ;;
                ondemand)
                    echo "50" > "$cpu/cpufreq/ondemand/up_threshold"
                    echo "20000" > "$cpu/cpufreq/ondemand/sampling_rate"
                    ;;
                conservative)
                    echo "60" > "$cpu/cpufreq/conservative/up_threshold"
                    echo "20" > "$cpu/cpufreq/conservative/down_threshold"
                    ;;
            esac
        fi
    done
fi

# Ajustes de GPU (Adreno, Mali, Exynos)
if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
    echo "performance" > /sys/class/kgsl/kgsl-3d0/devfreq/governor
    echo "1" > /sys/class/kgsl/kgsl-3d0/devfreq/adreno_min_pwrlevel
    echo "0" > /sys/class/kgsl/kgsl-3d0/devfreq/adreno_max_pwrlevel
fi

if [ -d "/sys/devices/platform/mali.0" ]; then
    echo "performance" > /sys/devices/platform/mali.0/devfreq/governor
fi

# I/O Tweaks (dinâmico)
if [ -f "/sys/block/mmcblk0/queue/scheduler" ]; then
    CURRENT_SCHED=$(cat /sys/block/mmcblk0/queue/scheduler | grep -o '\\[.*\\]' | tr -d '[]')
    case "$CURRENT_SCHED" in
        cfq|noop|deadline|mq-deadline)
            echo "$CURRENT_SCHED" > /sys/block/mmcblk0/queue/scheduler
            ;;
        *)
            echo "noop" > /sys/block/mmcblk0/queue/scheduler 
            ;;
    esac
fi

if [ -f "/sys/block/mmcblk0/queue/read_ahead_kb" ]; then
    echo "1024" > /sys/block/mmcblk0/queue/read_ahead_kb
fi

# Ajustes gerais do sistema
setprop persist.sys.force_highendgfx true
setprop debug.sf.hw 1
setprop debug.performance.tuning 1
setprop persist.sys.scrollingcache 3
setprop ro.hardware.egl.optimization 1
setprop persist.sys.ui.hw true
setprop debug.sf.latch_unsignaled 1 
setprop debug.renderengine.backend gl
setprop debug.sf.enable_hwc_vds 1
setprop ro.surface_flinger.max_frame_latency 2  
setprop ro.surface_flinger.max_frame_buffer_acquired_buffers 4

# Boost da UI
echo "1" > /proc/sys/kernel/sched_boost

# Function to write to a file
write() {
  local file="$1"
  shift

  [ -f "$file" ] && echo "$@" > "$file"
}

# update cpus for cpuset cgroup
if [ -d /sys/devices/system/cpu/cpufreq/policy6 ]; then
  write /dev/cpuset/foreground/cpus 0-7
  write /dev/cpuset/foreground/boost/cpus 6-7
  write /dev/cpuset/background/cpus 0-5
  write /dev/cpuset/system-background/cpus 0-5
  write /dev/cpuset/top-app/cpus 0-7
  write /dev/cpuset/top-app/boost/cpus 6-7
  write /dev/cpuset/ui/cpus 6-7
else
  write /dev/cpuset/foreground/cpus 0-7
  write /dev/cpuset/foreground/boost/cpus 4-7
  write /dev/cpuset/background/cpus 0-3
  write /dev/cpuset/system-background/cpus 0-3
  write /dev/cpuset/top-app/cpus 0-7
  write /dev/cpuset/top-app/boost/cpus 4-7
  write /dev/cpuset/ui/cpus 4-7
fi

# Disable compaction proactiveness
write /proc/sys/vm/compaction_proactiveness 0

# Disable watermark boost
write /proc/sys/vm/watermark_boost_factor 0

# multi-gen LRU
write /sys/kernel/mm/lru_gen/enabled y

# zram
write /sys/block/zram0/comp_algorithm lz4
write /proc/sys/vm/page-cluster 3
write /proc/sys/vm/swappiness 100
write /sys/kernel/mm/swap/vma_ra_enabled true

# kernel
write /proc/sys/kernel/sched_pelt_multiplier 4
write /proc/sys/kernel/sched_util_clamp_min_rt_default 0
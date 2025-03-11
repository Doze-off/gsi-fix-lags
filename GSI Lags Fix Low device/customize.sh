
sleep 1
ui_print " • Informações do módulo "
sleep 0.2
ui_print " • Nome            : GSI Lags Fix"
sleep 0.2
ui_print " • Desenvolvedor   : @NedTOP "
sleep 0.2
ui_print ""
ui_print " • Iniciando a instalação"
sleep 2
ui_print ""
ui_print " • Verificando o governador de CPU..."
CPU_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

if [ "$CPU_GOV" = "schedutil" ]; then
    ui_print ""
    ui_print " • Governador 'schedutil' encontrado "
    ui_print " • aplicando configurações. "
else
    ui_print " • Governador 'schedutil' não encontrado. "
    ui_print " • Usando 'interactive' como alternativa. "
fi
sleep 0.5
ui_print ""
ui_print " • Instalação concluída com sucesso! "

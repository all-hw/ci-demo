#!/usr/bin/env bash
#/opt/FVP_Corstone_SSE-300/models/Linux64_GCC-6.4/FVP_Corstone_SSE-300_Ethos-U55 -V "../VSI/audio/python" -f fvp_config.txt -a Objects/microspeech.axf -C mps3_board.uart0.shutdown_tag=CI_end_task --stat --cyclelimit 4800000000 $*
VHT_Corstone_SSE-300_Ethos-U55 -V "../VSI/audio/python" -f fvp_config.txt -a Objects/microspeech.axf -C mps3_board.uart0.shutdown_tag=CI_end_task --stat --cyclelimit 4800000000 $*

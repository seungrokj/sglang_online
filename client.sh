#!/bin/bash
CON="4 8 16 32 64 128 256"
INPUTS="3200"
OUTPUTS="800"

LOG="temp"
LOG_sum="bench_serving_summary_nocache_0206"

printf "%-15s" prompts                 2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" isl                     2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" osl                     2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" con                     2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" req_throughput          2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" median_e2e              2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" median_ttft             2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" median_tpot             2>&1 | tee -a ${LOG_sum}.log
printf "\n"                            2>&1 | tee -a ${LOG_sum}.log

for isl in $INPUTS; do
    for osl in $OUTPUTS; do
        for con in $CON; do
            #prompts=$con
            prompts=200
            echo "[RUNNING] prompts $prompts isl $isl osl $osl con $con"
            python3 -m sglang.bench_serving \
                --backend sglang \
                --dataset-name random \
                --random-range-ratio 1 \
                --num-prompt $prompts \
                --random-input $isl \
                --random-output $osl \
                --max-concurrency $con \
                2>&1 | tee ${LOG}.log

            rTh=$(grep -E "Request throughput" ${LOG}.log)
            e2eLat=$(grep -E "Median E2E Latency" ${LOG}.log)
            ttftLat=$(grep -E "Median TTFT" ${LOG}.log)
            tpotLat=$(grep -E "Median TPOT" ${LOG}.log)

            rTh_sp=(${rTh//:/ })
            e2eLat_sp=(${e2eLat//:/ })
            ttftLat_sp=(${ttftLat//:/ })
            tpotLat_sp=(${tpotLat//:/ })

            rTh_val=${rTh_sp[3]}
            e2eLat_val=${e2eLat_sp[4]}
            ttftLat_val=${ttftLat_sp[3]}
            tpotLat_val=${tpotLat_sp[3]}

            printf "%-15s" $prompts        2>&1 | tee -a ${LOG_sum}.log
            printf "%-15s" $isl            2>&1 | tee -a ${LOG_sum}.log
            printf "%-15s" $osl            2>&1 | tee -a ${LOG_sum}.log
            printf "%-15s" $con            2>&1 | tee -a ${LOG_sum}.log
            printf "%-15s" $rTh_val        2>&1 | tee -a ${LOG_sum}.log
            printf "%-15s" $e2eLat_val     2>&1 | tee -a ${LOG_sum}.log
            printf "%-15s" $ttftLat_val    2>&1 | tee -a ${LOG_sum}.log
            printf "%-15s" $tpotLat_val    2>&1 | tee -a ${LOG_sum}.log
            printf "\n"                    2>&1 | tee -a ${LOG_sum}.log
        done
    done
done

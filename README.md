# sglang_online benchmark quick test

## Launch sglang server
```bash
./server.sh
```

wait for this msg

[2025-02-07 00:39:11] INFO:     127.0.0.1:50120 - "POST /generate HTTP/1.1" 200 OK
[2025-02-07 00:39:11] The server is fired up and ready to roll!

## Access from a client
```bash
./client.sh
```
it will show this

| prompts | isl  | osl | con | req_throughput | median_e2e | median_ttft | median_tpot |
| ------- | ---- | --- | --- | -------------- | ---------- | ----------- | ----------- |
| 200.00  | 3200 | 800 | 4   |                |            |             |             |
| 200.00  | 3200 | 800 | 8   |                |            |             |             |
| 200.00  | 3200 | 800 | 16  |                |            |             |             |
| 200.00  | 3200 | 800 | 32  |                |            |             |             |
| 200.00  | 3200 | 800 | 64  |                |            |             |             |
| 200.00  | 3200 | 800 | 128 |                |            |             |             |

# sglang_online inference profiling

## install RPD and enable RPDT_AUTOFLUSH

```bash
git clone https://github.com/ROCm/rocmProfileData.git
apt-get install sqlite3 libsqlite3-dev
apt-get install libfmt-dev
cd rocmProfileData/
make
make install
cd ..
export RPDT_AUTOFLUSH=1
```

## Launch sglang server and enable RPD (runTracer.sh). Running it in background to hide RPD logs from the terminal.

```bash
export HSA_NO_SCRATCH_RECLAIM=1

nohup runTracer.sh python3 -m sglang.launch_server --model deepseek-ai/DeepSeek-V3 --tp 8 --trust-remote-code --disable-radix-cache &
```

After the sglang is initialized and the model is loaded to GPU memory, you can check this message 

```bash
grep ready nohup.out

# [2025-02-07 05:09:21] The server is fired up and ready to roll!
```

## Access from a client

```bash
prompts=16
con=16
isl=3200
osl=800

python3 -m sglang.bench_serving \
	--backend sglang \
	--dataset-name random \
	--random-range-ratio 1 \
	--num-prompt $prompts \
	--random-input $isl \
	--random-output $osl \
	--max-concurrency $con 

```

After the client collects the performance data, turn off the sglang server by this command

```bash
fg

# terminate the sglang server
# Ctrl+c
```

## RPD profile data conversion and visualization

Trim the profile data, by --start and --end arguments in rpd2tracing.py and compress the json trace. 

```bash
python rocmProfileData/tools/rpd2tracing.py trace.rpd trace.out --start 98% --end 100%

# /workspace/rocmProfileData/tools/rpd2tracing.py:223: SyntaxWarning: invalid escape sequence '\('
#   '''
# Timestamps:
#             first:      98564390209.637 us
#              last:      99189995987.185 us
#          duration:      625.605777548 seconds
# 
# Filter: where rocpd_api.start/1000 >= 99177483871.63405 and rocpd_api.start/1000 <= 99189995987.185
# Output duration: 12.512115550949098 seconds

gzip -c trace.json > trace.json.gz
```

Open trace.json.gz with the perfetto visualizer. 

https://ui.perfetto.dev/

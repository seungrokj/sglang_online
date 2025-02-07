# sglang_online

```bash
./server.sh
```

wait for this msg

[2025-02-07 00:39:11] INFO:     127.0.0.1:50120 - "POST /generate HTTP/1.1" 200 OK
[2025-02-07 00:39:11] The server is fired up and ready to roll!


```bash
./client.sh
```
it will show this

prompts|isl|osl|con|req_throughput|median_e2e|median_ttft|median_tpot
200.00|3200|800|4||||
200.00|3200|800|8||||
200.00|3200|800|16||||
200.00|3200|800|32||||
200.00|3200|800|64||||
200.00|3200|800|128||||

#!/usr/bin/env bash
nohup ttyd -p 7681 -W -t fontSize=40 -t cols=80 bash > ./ttyd.log 2>&1 &

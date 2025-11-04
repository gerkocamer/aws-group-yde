#!/bin/bash
cd /home/ec2-user/simple-webapp
nohup python3 app.py > app.log 2>&1 &

#!/bin/bash
rm -f /root/gpu-burn/gpu_burn
cd /root/gpu-burn/ ; make
/root/gpu-burn/gpu_burn -m ${1}% ${2}


#!/bin/bash
echo "=== DEBUG MODULE ==="
echo "Test get_external_disks:"
external=$(lsblk -o NAME,TYPE,SIZE,MODEL | awk 'NR>1 && $2 == "disk" && $1 !~ /^nvme0n1$/ { if ($1 ~ /^sd[a-z]$/) { print $1 } }' | head -5)
echo "External: '$external'"
external_count=$(echo -n "$external" | wc -l)
echo "External count: $external_count"

echo ""
echo "Test get_mounted_disks:"
mounted=$(df -h | awk 'NR>1 && !/\/dev\/loop/ && $1 ~ /^\/dev\/sd[a-z]/ && $6 !~ /^\/$/ && $6 !~ /^\/boot$/ && $6 !~ /^\/home$/ {print $1 "|" $6 "|" $3 "|" $5}' | head -5)
echo "Mounted: '$mounted'"
mounted_count=$(echo -n "$mounted" | wc -l)
echo "Mounted count: $mounted_count"

echo ""
echo "Should hide module? $([ $external_count -eq 0 ] && echo "YES" || echo "NO")"
echo "=== FIN DEBUG ==="

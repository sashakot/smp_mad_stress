mst_dev=$1
vl15_cred=$2
echo "--- Each credit is 128 [B] ---"
echo "setting Port0 vl15 credits to $vl15_cred"
mcra $mst_dev 0x261020.0:13 $vl15_cred #.port.link.port[0].flowctrl.buffers.max_stat_cred15
echo "setting Port0 vl3 credits to 0x100"
mcra $mst_dev 0x261008.16:13 0x100 #.port.link.port[0].flowctrl.buffers.max_stat_cred3

mcra $mst_dev 0x261030.0:1 1 #Llu->port[portid].flowctrl.buffers.refresh_free


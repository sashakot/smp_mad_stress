mst_dev=$1
echo "--- Each credit is 128 [B] ---"
echo "Port0 vl15 credits"
mcra $mst_dev 0xd9020.0:12 #.port.link.port[0].flowctrl.buffers.max_stat_cred15
echo "Port0 dynamic credits"
mcra $mst_dev 0xd9020.16:12 #.port.link.port[0].flowctrl.buffers.max_dyn1_cred
echo "Port0 vl0 credits"
mcra $mst_dev 0xd9000.0:12 #.port.link.port[0].flowctrl.buffers.max_stat_cred0
echo "Port0 vl1 credits"
mcra $mst_dev 0xd9000.16:12 #.port.link.port[0].flowctrl.buffers.max_stat_cred1
echo "Port0 vl2 credits"
mcra $mst_dev 0xd9008.0:12 #.port.link.port[0].flowctrl.buffers.max_stat_cred2
echo "Port0 vl3 credits"
mcra $mst_dev 0xd9008.16:12 #.port.link.port[0].flowctrl.buffers.max_stat_cred3


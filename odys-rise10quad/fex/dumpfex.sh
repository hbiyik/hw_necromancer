# Unlike, other allwinner devices,Script.bin is not present in the vfat partition(nanda) as file.
# Instead, It is located 0x43000000, it's size is 0x00020000. script.bin can be extracted from /dev/mem using mmap() or sunxi-tools firmware_extractor.
dd if=/dev/mem of=script.bin bs=1 count=131072 skip=1124073472    

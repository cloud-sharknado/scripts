# Simple one-liners for memory information/management
#
# free, check memory usage
free -m
#              == Sample output ==
#               total       used       free     shared    buffers     cached
#  Mem:          7930       4103       3826          0         59       2060
#  -/+ buffers/cache:       1983       5946
#  Swap:        15487          0      15487

# dmidecode memory information (hardware releted informations)
dmidecode --type 17
# or
dmidecode --type memory
#              == Sample output ==
#  dmidecode 2.11
#  SMBIOS 2.5 present.
#  Handle 0x0017, DMI type 17, 27 bytes
#  Memory Device
#  	Array Handle: 0x0016
#  	Error Information Handle: No Error
#  	Total Width: 72 bits
#  	Data Width: 64 bits
#  	Size: 2048 MB
#  	Form Factor: DIMM
#  	Set: 1
#  	Locator: DIMM1A
#  	Bank Locator: Bank1
#  	Type: DDR2
#  	Type Detail: Synchronous
#  	Speed: 667 MHz
#  	Manufacturer: 5185
#  	Serial Number: 05009F22
#  	Asset Tag: Not Specified
#  	Part Number: 72T232220HFA3SB
  	
# safely clean memory cache
sync; echo 3 > /proc/sys/vm/drop_caches

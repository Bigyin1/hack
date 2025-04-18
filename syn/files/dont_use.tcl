####################################################################
## Dont Use Cells 
####################################################################

set_db [get_db base_cells *FSD_* ]  .dont_use true
set_db [get_db base_cells *LSRDPQ_* ]  .dont_use true

# High speed High drive buffers\inverters
# set_db [get_db base_cells *BFHSX32* ]  .dont_use true
# set_db [get_db base_cells *BFHSX16* ] .dont_use true
# set_db [get_db base_cells *BFHSX8* ]  .dont_use true

# set_db [get_db base_cells *IVHSX32* ]  .dont_use true
# set_db [get_db base_cells *IVHSX16* ]  .dont_use true
# set_db [get_db base_cells *IVHSX8* ]   .dont_use true

# Low leakage High drive buffers\inverters
# set_db [get_db base_cells *BFLLX32* ]  .dont_use true
# set_db [get_db base_cells *BFLLX16* ] .dont_use true
# set_db [get_db base_cells *BFLLX8* ]  .dont_use true

# set_db [get_db base_cells *IVLLX32* ]  .dont_use true
# set_db [get_db base_cells *IVLLX16* ]  .dont_use true
# set_db [get_db base_cells *IVLLX8* ]   .dont_use true

# Low drive cells
# set_db [get_db base_cells *X05 ]   .dont_use true

# Technology default
# set_db [get_db base_cells M_*  ]   .dont_use true
# set_db [get_db base_cells F_*  ]   .dont_use true
# set_db [get_db base_cells BT*  ]   .dont_use true
# set_db [get_db base_cells DLY* ]   .dont_use true
# set_db [get_db base_cells BK1HS]   .dont_use true
# set_db [get_db base_cells ITS* ]   .dont_use true
# set_db [get_db base_cells CTB* ]   .dont_use true
# set_db [get_db base_cells SC*  ]   .dont_use true
# set_db [get_db base_cells CBUF*]   .dont_use false

# Scan flip-flop
# set_db [get_db base_cells FD1T*]   .dont_use true
# set_db [get_db base_cells FD2T*]   .dont_use true
# set_db [get_db base_cells FDH2T*]  .dont_use true
# set_db [get_db base_cells FD3T*]   .dont_use true
# set_db [get_db base_cells FD4T*]   .dont_use true
# set_db [get_db base_cells FD7T*]   .dont_use true

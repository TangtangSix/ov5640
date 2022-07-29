set_global_assignment -entity "sdram_interface" -library "lib_sdram_interface" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "sdram_interface" -library "lib_sdram_interface" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "sdram_interface" -library "lib_sdram_interface" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_sdram_interface" -name SPD_FILE [file join $::quartus(sip_path) "../sdram_interface.spd"]
set_global_assignment -library "lib_sdram_interface" -name MISC_FILE [file join $::quartus(sip_path) "../../sdram_interface.qsys"]

set_global_assignment -library "lib_sdram_interface" -name MISC_FILE [file join $::quartus(sip_path) "sdram_interface.v"]
set_global_assignment -library "lib_sdram_interface" -name MISC_FILE [file join $::quartus(sip_path) "submodules/sdram_interface_sdram_interface.v"]

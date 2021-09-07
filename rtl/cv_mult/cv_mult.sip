set_global_assignment -entity "cv_mult" -library "lib_cv_mult" -name IP_TOOL_NAME "altera_mult_add"
set_global_assignment -entity "cv_mult" -library "lib_cv_mult" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "cv_mult" -library "lib_cv_mult" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_cv_mult" -name SPD_FILE [file join $::quartus(sip_path) "cv_mult.spd"]

set_global_assignment -library "lib_cv_mult" -name MISC_FILE [file join $::quartus(sip_path) "cv_mult_sim/cv_mult.v"]

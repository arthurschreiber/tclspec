package ifneeded spec 0.1 "source $dir/lib/spec/spec.tcl"
package ifneeded spec/autorun 0.1 "source $dir/lib/spec/autorun.tcl"

lappend auto_path [file join [file dirname [info script]] "vendor" "try"]
lappend auto_path [file join [file dirname [info script]] "vendor" "at_exit"]
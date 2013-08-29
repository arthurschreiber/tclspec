package ifneeded "TclOO::ext" 1.0 {
    package require "TclOO::ext::reference_countable"
    package require "TclOO::ext::autorelease_pool"
    package require "TclOO::ext::class"
}

package ifneeded "TclOO::ext::reference_countable" 1.0 [list source [file join $dir "lib" "reference_countable.tcl"]]
package ifneeded "TclOO::ext::autorelease_pool"    1.0 [list source [file join $dir "lib" "autorelease_pool.tcl"]]
package ifneeded "TclOO::ext::class"               1.0 [list source [file join $dir "lib" "class.tcl"]]

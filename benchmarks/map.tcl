set auto_path [concat [file join [file dirname [info script]] ".."] $auto_path]

package require underscore

set numbers [list]
for {set i 0} {$i < 100} { incr i } { lappend numbers $i }

puts "mapping using foreach with expression"
puts [time {
    set result [list]
    foreach num $numbers {
        lappend result [expr { $num * $num }]
    }
} 1000]

puts "_::map with expression"
puts [time {
    _::map $numbers {{num} {
        expr { $num * $num }
    }}
} 1000]
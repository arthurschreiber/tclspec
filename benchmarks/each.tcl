set auto_path [concat [file join [file dirname [info script]] ".."] $auto_path]

package require underscore

set numbers [list]
for {set i 0} {$i < 100} { incr i } { lappend numbers $i }

puts "foreach with empty body"
puts [time {
    foreach num $numbers {
        # Do nothing...
    }
} 1000]

puts "_::each with empty body"
puts [time {
    _::each $numbers {{num} {
        # Do nothing...
    }}
} 1000]

puts "foreach with expression"
puts [time {
    foreach num $numbers {
        expr { $num * $num }
    }
} 1000]

puts "_::each with expression"
puts [time {
    _::each $numbers {{num} {
        expr { $num * $num }
    }}
} 1000]
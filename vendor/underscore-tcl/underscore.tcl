# underscore.tcl - Collection of utility methods
#
# Inspired by Underscore.js - http://documentcloud.github.com/underscore/ and
# the Ruby Enumerable module.
#
# This package provides a collection of different utility methods, that try to
# bring functional programming aspects known from other programming languages
# like Ruby or JavaScript to Tcl.
package provide underscore 0.1

namespace eval _ {
    # Yields a block of code in a specific stack-level.
    #
    # This function yields the passed block of code in a seperate stack frame
    # (by wrapping it into an ::apply call), but allows easy access to
    # surrounding variables using the tcl-native upvar mechanism.
    #
    # Yielding the code in an anonymous proc prevents the leakage of variable
    # definitions, while still giving the block access to surrounding variables
    # using upvar.
    #
    # @example Calculating the first n Fibonnacci numbers
    #   proc fib_up_to { max block } {
    #       set i1 [set i2 1]
    #
    #       while { $i1 <= $max } {
    #           _::yield $block $i1
    #           set tmp [expr $i + $i2]
    #           set i1 $i2
    #           set i2 $tmp
    #       }
    #   }
    #
    #   fib_up_to 50 {{n} { puts $n }} ;# prints the fibonnaci sequence up to 50
    #
    # @example Automatic resource cleanup
    #   # Guarantees that the file descriptor is closed,
    #   # even in case of an error being raised while executing the block.
    #   proc file_open { path mode block } {
    #       open $fd
    #
    #       # Catch any exceptions that might happen
    #       set error [catch { _::yield $block $fd } value options]]
    #
    #       catch { close $fd }
    #
    #       if { $error } {
    #           # if an exception happened, rethrow it
    #           return {*}$options $value
    #       } else {
    #           # Do nothing
    #           return
    #       }
    #   }
    #
    #   file_open "/tmp/test" "w" {{fd} {
    #       puts $fd "test"
    #   }}
    #
    # If you want to return from the stack frame where the method that yields a block
    # was called from, you can use 'return -code return'.
    #
    # @example Returning from the stack frame that called the yielding method.
    #   proc return_to_calling_frame {} {
    #       _::each {1 2 3 4} {{item} {
    #           if { $item == 2 } {
    #               # Stops the iteration and will return "done" from "return_to_calling_frame"
    #               return -code return "done"
    #           }
    #       }}
    #       # This return will not be executed
    #       return "fail"
    #   }
    #
    # 'return -code break ?value?' and 'return -code continue ?value?' have special
    # meanings inside a block.
    #
    # @example Passing a block down, by specifying a yield level
    #   # Reverse each, like _::each, but in reverse
    #   proc reverse_each { list block } {
    #       _::each [lreverse $list] {{args} {
    #           # Include the passed block
    #           upvar block block
    #
    #           # we have to increase the yield level here, as we want to
    #           # execute the block on the same stack level as reverse_each
    #           # was called on
    #           uplevel 1 [list _::yield $block {*}$args]
    #       }}
    #   }
    #
    # @example Passing a block down by upleveling the call to each.
    #   # Reverse each, like _::each, but in reverse
    #   proc reverse_each { list block } {
    #       uplevel [list _::each [lreverse $list] $block]
    #   }
    #
    # @param block_or_proc The block (anonymous function) or proc to be executed
    #   with the passed arguments. If it's a block, it can be either in the form
    #   of {args block} or {args block namespace} (see the documentation for ::apply).
    # @param args The arguments with which the passed block should be called.
    #
    # @return Return value of the block.
    proc yield { block_or_proc args } {
        # Stops type shimmering of $block_or_proc when calling llength directly
        # on it, which in turn causes the lambda expression to be recompiled
        # on each call to _::yield
        set block_dup [concat $block_or_proc]

        catch {
            if { [llength $block_dup] == 1 } {
                uplevel 2 [list $block_or_proc {*}$args]
            } else {
                uplevel 2 [list apply $block_or_proc {*}$args]
            }
        } result options

        dict incr options -level 1
        return -options $options $result
    }

    # Iterates over the passed list, yielding each element in turn to the
    # passed iterator
    proc each { list iterator } {
        foreach item $list {
            yield $iterator $item
        }

        return $list
    }

    proc map { list iterator } {
        set result [list]

        foreach item $list {
            set status [catch { yield $iterator $item } return_value options]

            switch -exact -- $status {
                0 - 4 {
                    # 'normal' return and errors
                    lappend result $return_value
                }
                3 {
                    # 'break' should return immediately 
                    return $return_value
                }
                default {
                    # Just pass through everything else
                    return -options $options $return_value
                }
            }
        }

        return $result
    }

    proc reduce { list iterator memo } {
        foreach item $list {
            set memo [yield $iterator $memo $item]
        }
        return $memo
    }

    # Executes the passed iterator with each element of the passed list.
    # Returns true if the passed block never returns a 'falsy' value.
    #
    # When no explicit iterator is passed, all? will return true
    # if none of the list elements is a falsy value.
    proc all? { list {iterator {{x} { return $x }}} } {
        foreach e $list {
            if { [string is false [yield $iterator $e]] } {
                return false
            }
        }

        return true
    }
    interp alias {} ::_::every? {} ::_::all?
    namespace export all? every?

    # Executes the passed iterator with each element of the passed list.
    # Returns true if the passed block returns at least one value that
    # is not 'falsy'.
    #
    # When no explicit iterator is passed, any? will return true
    # if at least one of the list elements is not a falsy value.
    proc any? { list {iterator {{x} { return $x }}} } {
        foreach e $list {
            if { [expr { ![string is false [yield $iterator $e]] }] } {
                return true
            }
        }

        return false
    }
    interp alias {} ::_::some? {} ::_::any?
    namespace export some? any?

    # Returns the first n elements from the passed list.
    proc first { list {n 1}} {
        lrange $list 0 $n-1
    }

    # Returns all elements from the passed list excluding the last n.
    proc initial { list {n 1}} {
        lrange $list 0 end-$n
    }

    proc index_of { list value {is_sorted false} } {
        if { ![string is false $is_sorted] } {
            lsearch -sorted -exact $list $value
        } else {
            lsearch -exact $list $value
        }
    }

    # Returns a sorted copy of list. Sorting is based on the return
    # values of the execution of the iterator for each item.
    proc sort_by { list iterator } {
        set list_to_sort [_::map $list {{item} {
            upvar iterator iterator
            list [uplevel [list yield $iterator $item] $item
        }}]

        set sorted_list [lsort $list_to_sort]

        _::map $sorted_list {{pair} {
            lindex $pair 1
        }}
    }

    # Executes the passed block n times.
    proc times { n iterator } {
        for {set i 0} {$i < $n} {incr i} {
            yield $iterator $i
        }
    }

    proc take_while { list iterator } {
        set result [list]

        foreach item $list {
            if { ![yield $iterator $item] } {
                break
            }

            lappend result $item
        }

        return $item
    }

    proc group_by { list iterator } {
        set result [dict create]

        foreach item $list {
            dict lappend result [yield $iterator $item] $item
        }

        return $result
    }
}
package provide "TclOO::ext::autorelease_pool" "1.0"

oo::class create AutoreleasePool {
    self method add_object { object } {
        set pool [my current_pool]
        if { $pool ne "" } {
            $pool add_object $object
        } else {
            puts stderr "`autorelease` called without pool for $object of class [info object class $object]"
        }
    }

    self method current_pool { } {
        my variable current_pool
        if { [info exists current_pool] } {
            return $current_pool
        }
    }

    self method set_current_pool { pool } {
        my variable current_pool
        set current_pool $pool
    }

    constructor { } {
        my variable objects
        set objects [list]

        my variable parent
        set parent [AutoreleasePool current_pool]
        if { $parent ne "" } {
            $parent set_child [self]
        }
        AutoreleasePool set_current_pool [self]
    }

    destructor {
        my variable objects
        foreach object $objects {
            $object release
        }

        my variable parent
        if { [AutoreleasePool current_pool] == [self] } {
            AutoreleasePool set_current_pool $parent
        }

        if { $parent ne "" } {
            $parent set_child ""
        }
    }

    method parent { } {
        my variable parent
        return $parent
    }

    method child { } {
        my variable child
        if { [info exists child] } {
            return $child
        }
    }

    method set_child { new_child } {
        my variable child
        set child $new_child
    }

    method add_object { object } {
        my variable objects
        lappend objects $object
    }

    method retain {} {
        return -code error "Don't call `retain' on an AutoreleasePool"
    }

    method autorelease {} {
        return -code error "Don't call `autorelease' on an AutoreleasePool"
    }

    method release {} {
        my destroy
    }
}

proc autoreleasepool { block } {
    set pool [AutoreleasePool new]

    tcl::control::try {
        uplevel 1 $block        
    } finally {
        $pool release
    }
}

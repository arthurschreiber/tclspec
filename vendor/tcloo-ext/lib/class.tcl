package require "TclOO::ext::reference_countable" "1.0"

package provide "TclOO::ext::class" "1.0"

oo::class create ext::class {
    superclass oo::class

    constructor { args } {
        # First, create the MetaClass.
        #
        # This ensures that e.g. the ::oo::define::classmethod
        # works correctly when called inside the definition
        # block of a class.
        oo::class create [self].Meta

        # Now, forward to the oo::class constructor.
        #
        # This will execute the definition block and will make sure
        # that the e.g. we have the list of superclasses defined.
        next {*}$args

        # Now, collect a list of superclasses and get their MetaClasses
        # (if they exist). Take this list of MetaClasses and set them as
        # superclasses of our MetaClass.
        set superclasses [list "oo::class"]
        foreach class [info class superclasses [self]] {
            if { [info object isa object "${class}.Meta"] && [info object isa class "${class}.Meta"] } {
                lappend superclasses "${class}.Meta"
            }
        }
        oo::define [self].Meta superclass {*}[lreverse $superclasses]

        # Finally, change our new class to be an instance of our MetaClass.
        # This will set up the inheritance chain and make everything work
        # correctly.
        oo::objdefine [self] class "[self].Meta"

        # Include ReferenceCountable as a superclass to make
        # reference counting available to all ext::class classes.
        if { "ReferenceCountable" ni [info class superclasses [self]] } {
            oo::define [self] superclass -append "ReferenceCountable"
        }
    }
}

proc ::oo::define::meta { args } {
    if { [llength $args] == 0 } {
        return -code error "wrong # args: should be \"[lindex [info level 0] 0] arg ?arg ...?\""
    }

    set class [namespace which [lindex [info level -1] 1]]

    if { ![info object isa object $class.Meta] || ![info object isa class $class.Meta] } {
        return -code error "\"$class\" has no MetaClass!"
    }

    ::oo::define $class.Meta {*}$args
}

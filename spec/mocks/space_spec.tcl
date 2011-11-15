lappend auto_path [file join [file dirname [info script]] ".." ".." "lib"]
package require spec/autorun

source [file join [file dirname [info script]] ".." "spec_helper.tcl"]

describe "::Spec::Mocks::Space" {
    before each {
        my set space [Spec::Mocks::Space new]

        set klazz [Class new]
        $klazz instproc spec_verify {} {
            my incr verified 1
        }
        $klazz instproc spec_reset {} {
            my set reset true
        }
        $klazz instproc verified? {} {
            expr { [my exists verified] && [my set verified] }
        }
        $klazz instproc reset? {} {
            expr { [my exists reset] && [my set reset] }
        }

        my set m1 [$klazz new]
        my set m2 [$klazz new]
    }

    it "verifies all mocks within" {
        my instvar space
        $space add [my set m1]
        $space add [my set m2]

        $space verify_all

        expect [[my set m1] verified?] to be true
        expect [[my set m2] verified?] to be true
    }

    it "resets all mocks within" {
        my instvar space
        $space add [my set m1]
        $space add [my set m2]

        $space reset

        expect [[my set m1] reset?] to be true
        expect [[my set m2] reset?] to be true
    }

    it "clears internal mocks on reset_all" {
        my instvar space
        $space add [my set m1]
        $space reset_all
        expect [$space empty?] to be true
    }
}
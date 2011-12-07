lappend auto_path [file join [file dirname [info script]] ".." ".." "lib"]
package require spec/autorun

source [file join [file dirname [info script]] ".." "spec_helper.tcl"]

describe "::Spec::Mocks::Space" {
    before each {
        set space [Spec::Mocks::Space new]

        set class [xotcl::Class new]
        $class instproc spec_verify {} {
            my incr verified 1
        }
        $class instproc spec_reset {} {
            my set reset true
        }
        $class instproc verified? {} {
            expr { [my exists verified] && [my set verified] }
        }
        $class instproc reset? {} {
            expr { [my exists reset] && [my set reset] }
        }

        set m1 [$class new]
        set m2 [$class new]
    }

    it "verifies all mocks within" {
        $space add $m1
        $space add $m2

        $space verify_all

        expect [$m1 verified?] to be true
        expect [$m2 verified?] to be true
    }

    it "resets all mocks within" {
        $space add $m1
        $space add $m2

        $space reset

        expect [$m1 reset?] to be true
        expect [$m2 reset?] to be true
    }

    it "clears internal mocks on reset_all" {
        $space add $m1
        $space reset_all
        expect [$space empty?] to be true
    }
}
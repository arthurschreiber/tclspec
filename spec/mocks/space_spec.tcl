source [file join [file dirname [info script]] ".." "spec_helper.tcl"]

describe "::Spec::Mocks::Space" {
    before each {
        set space [Spec::Mocks::Space new]

        set class [nx::Class new {
            :public method spec_verify {} {
                incr :verified 1
            }
            :public method spec_reset {} {
                set :reset true
            }
            :public method verified? {} {
                expr { [info exists :verified] && ${:verified} > 0 }
            }
            :public method reset? {} {
                expr { [info exists :reset] && ${:reset} }
            }
        }]

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

        $space reset_all

        expect [$m1 reset?] to be true
        expect [$m2 reset?] to be true
    }

    it "clears internal mocks on reset_all" {
        $space add $m1
        $space reset_all
        expect [$space empty?] to be true
    }
}
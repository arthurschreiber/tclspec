lappend auto_path [file join [file dirname [info script]] ".."]
package require spec/autorun

source [file join [file dirname [info script]] "spec_helper.tcl"]

describe "::Spec.configure" {
    it "calls the passed block with an configuration instance" {
        set called false

        Spec configure { c {
            set called true
            expect [::Spec::Configuration info instances $c] to equal $c
        } }

        expect $called to be true
    }

    it "always calls the block with the same configuration instance" {
        Spec configure { c {
            set previous_config $c
        } }

        Spec configure { c {
            expect $c to equal $previous_config
        } }
    }
}

describe "::Spec.configuration" {
    it "returns a configuration instance" {
        set c [Spec configuration]
        expect [::Spec::Configuration info instances $c] to equal $c
    }

    it "always returns the same configuration instance" {
        set c [Spec configuration]
        expect [Spec configuration] to equal $c
    }
}

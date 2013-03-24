source [file join [file dirname [info script]] "spec_helper.tcl"]

describe "::Spec.configure" {
    it "calls the passed block with an configuration instance" {
        set called false

        Spec configure { c {
            upvar called called
            set called true
            uplevel [list expect [info object class $c] to equal "::Spec::Configuration"]
        } }

        expect $called to be true
    }

    it "always calls the block with the same configuration instance" {
        Spec configure { c {
            upvar previous_config previous_config
            set previous_config $c
        } }

        Spec configure { c {
            upvar previous_config previous_config
            uplevel [list expect $c to equal $previous_config]
        } }
    }
}

describe "::Spec.configuration" {
    it "returns a configuration instance" {
        expect [info object class [Spec configuration]] to equal "::Spec::Configuration"
    }

    it "always returns the same configuration instance" {
        expect [Spec configuration] to equal [Spec configuration]
    }
}

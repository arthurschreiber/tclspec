lappend auto_path [file join [file dirname [info script]] ".." "lib"]
package require spec/autorun

source [file join [file dirname [info script]] "spec_helper.tcl"]

describe "an example" {
    my instproc help {} {
        return "available"
    }

    it "has access to methods defined in its group" {
        expect [my help] to equal "available"
    }
}

describe "an example" {
    my instproc help {} {
        return "available"
    }

    describe "in a nested group" {
        it "has access to methods defined in its parent group" {
            expect [my help] to equal "available"
        }
    }
}

Class create HelpersModule
HelpersModule instproc help {} {
    return "available"
}

describe "an example" {
    my instmixin HelpersModule

    it "has access to methods defined in mixins included in its group" {
        expect [my help] to equal "available"
    }
}
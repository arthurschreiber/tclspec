lappend auto_path [file join [file dirname [info script]] ".." "lib"]
package require spec/autorun

source [file join [file dirname [info script]] "spec_helper.tcl"]

describe "an example" {
    proc help {} {
        return "available"
    }

    it "has access to methods defined in its group" {
        expect [::xotcl::my help] to equal "available"
    }
}

describe "an example" {
    proc help {} {
        return "available"
    }

    describe "in a nested group" {
        it "has access to methods defined in its parent group" {
            expect [::xotcl::my help] to equal "available"
        }
    }
}

::xotcl::Class create HelpersModule
HelpersModule instproc help {} {
    return "available"
}

describe "an example" {
    ::xotcl::my instmixin HelpersModule

    it "has access to methods defined in mixins included in its group" {
        expect [::xotcl::my help] to equal "available"
    }
}
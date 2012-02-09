lappend auto_path [file join [file dirname [info script]] ".."]
package require spec/autorun

source [file join [file dirname [info script]] "spec_helper.tcl"]

describe "::Spec::Configuration" {
    before each {
        set configuration [::Spec::Configuration new]
    }

    it "has an empty list of formatters" {
        expect [llength [$configuration formatters]] to equal 0
    }

    it "allows adding the documentation formatter using add_formatter" {
        $configuration add_formatter "doc"

        set formatters [$configuration formatters]

        expect [llength $formatters] to equal 1
        expect [[lindex $formatters 0] info class] to equal ::Spec::Formatters::DocumentationFormatter
    }

    it "allows adding the progress formatter using add_formatter" {
        $configuration add_formatter "progress"

        set formatters [$configuration formatters]

        expect [llength $formatters] to equal 1
        expect [[lindex $formatters 0] info class] to equal ::Spec::Formatters::ProgressFormatter
    }

    describe ".reporter" {
        describe "on first call" {
            it "initializes a new Reporter with the previously registered formatters" {
                $configuration add_formatter "doc"
                set reporter [$configuration reporter]
                expect [$reporter formatters] to equal [$configuration formatters]
            }

            it "initializes a new Reporter with a progress formatter if no formatter is registered" {
                set reporter [$configuration reporter]
                set formatter [lindex [$reporter formatters] 0]
                expect [$formatter info class] to equal ::Spec::Formatters::ProgressFormatter
            }
        }
    }
}
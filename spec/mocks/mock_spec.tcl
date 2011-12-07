lappend auto_path [file join [file dirname [info script]] ".." ".."]
package require spec/autorun

source [file join [file dirname [info script]] ".." "spec_helper.tcl"]

namespace eval Spec::Mocks {}


Class create MethodsMixin
MethodsMixin instproc should_receive { } {
    # Add a message expectation
}

MethodsMixin instproc should_not_receive { proc } {
    # Add a negative message expectation
}

MethodsMixin instproc stub { proc } {
    # Add a stub
}

MethodsMixin instproc unstub { proc } {
    # Remove a stub
}

MethodsMixin instproc spec_verify { } {
    # Verify and reset the mock
}

MethodsMixin instproc spec_reset { } {
    # Reset the Mock
}


Class create Spec::Mocks::Mock

::Spec::Mocks::Mocks instmixin MethodsMixin
::Spec::Mocks::Mock instproc init { description } {
    my set description $description
}

::Spec::Mocks::Mock instproc spec_verify { } {
    my set description $description
}

Class create MethodDouble
MethodDouble instproc init { object method_name } {
    my set object $object
    my set method_name $method_name
}

MethodDouble instproc setup { } {
    # Add the object to the Mock Space,
    # call store_original_method and install_mock_method
}

MethodDouble instproc store_original_method { } {
    # Check whether the object has the passed proc defined
    # as an object proc.
    # If it is, we have to stash it.
    # If it doesn't, there's nothing to do
}

MethodDouble instproc install_mock_method { } {
    # Replace the method with something that notifies
    # the mock proxy that the method was called
}

MethodDouble instproc restore_original_method { } {
    # Check whether the method was stashed and restore it if it was
}

MethodDouble instproc verify { } {
    # Go through the expectations and
}

MethodDouble instproc reset { } {
    # Restore the original method and clear
}

MethodDouble instproc clear { } {
    # Remove stubs and expectations
}

describe "::Spec::Mocks::Mock" {
    before each {
        my set mock [::Spec::Mocks::Mock new "test double"]
    }

    it "passes when not receiving message specified as not to be received" {
        my instvar mock
        $mock should_not_receive "not_expected"
        $mock spec_verify
    }

    it "fails when receiving message specified as not to be received" {
        my instvar mock
        $mock should_not_receive "not_expected"
        expect {
            $mock not_expected
        } to raise_error -code MockExpectationError -message "(Double 'test double').not_expected(no args)\n    expected: 0 times\n    received: 1 time"
    }
}
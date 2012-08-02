source [file join [file dirname [info script]] ".." ".." "spec_helper.tcl"]

describe "::Spec::Mocks::nx::Mock" {
    before each {
        set mock [::Spec::Mocks::nx::Mock new -name "test double"]
    }

    after each {
        $mock spec_reset
    }

    it "passes when not receiving message specified as not to be received" {
        $mock should_not_receive "not_expected"
        $mock spec_verify
    }

    it "passes when not receiving message specified as not to be received with different args" {
        $mock should_not_receive "message" -with [list "unwanted text"]
        $mock message "other text"
        $mock spec_verify
    }

    it "fails when receiving message specified as not to be received" {
        $mock should_not_receive "not_expected"
        expect {
            $mock not_expected
        } to raise_error -code ::Spec::Mocks::ExpectationError
    }

    it "fails when receiving message specified as not to be received with args" {
        $mock should_not_receive "not_expected" -with [list "unexpected text"]
        expect {
            $mock not_expected "unexpected text"
        } to raise_error -code ::Spec::Mocks::ExpectationError
    }

    it "passes when receiving messages specified as not to be received with wrong args" {

    }

    it "allows blocks to calculate return values" {
        $mock should_receive "something" -with [list "a" "b" "c"] { {a b c} {
            join [list $a $b $c] ""
        } }

        expect [$mock something "a" "b" "c"] to equal "abc"
        $mock spec_verify
    }

    it "allows parameter as return value" {

    }

    it "returns the previously stubbed value if no return value was set" {
        $mock stub "something" -with [list "a" "b" "c"] { {a b c} {
            join [list $a $b $c] ""
        } }
        $mock should_receive "something" -with [list "a" "b" "c"]

        expect [$mock something "a" "b" "c"] to equal "abc"
        $mock spec_verify
    }

    it "returns nothing if no return value is set and there is no previously stubbed value" {
        $mock should_receive "something" -with [list "a" "b" "c"]

        expect [$mock something "a" "b" "c"] to equal ""
        $mock spec_verify
    }

    it "raises an exception if args don't match when method called" {

    }

    describe "even when a similar expectation with different arguments exist" {
        it "raises an exception if args don't match when method called, correctly reporting offending arguments" {
            $mock should_receive "something" -with [list "a" "b" "c"] -once
            $mock should_receive "something" -with [list "z" "x" "c"] -once

            # TODO: Check error message
            expect {
                $mock something "a" "b" "c"
                $mock something "z" "x" "g"
            } to raise_error -code ::Spec::Mocks::ExpectationError
        }
    }

    it "raises exception if args don't match when method called even when the method is stubbed" {
        $mock stub "something"
        $mock should_receive "something" -with [list "a" "b" "c"]

        # TODO: Check error message
        expect {
            $mock something "a" "d" "c"
            $mock spec_verify
        } to raise_error -code ::Spec::Mocks::ExpectationError
    }

    it "raises exception if args don't match when method called even when using null_object" {
        $mock as_null_object
        $mock should_receive "something" -with [list "a" "b" "c"]

        # TODO: Check error message
        expect {
            $mock something "a" "d" "c"
            $mock spec_verify
        } to raise_error -code ::Spec::Mocks::ExpectationError
    }

    it "fails if unexpected method is called" {
        # TODO: Check error message
        expect {
            $mock something "a" "b" "c"
        } to raise_error -code ::Spec::Mocks::ExpectationError
    }

    it "uses the passed block for expectation if provided" {
        # TODO: save the _namespace_ in which a method double is called.
        # Then apply the method double inside that namespace when it is
        # actually invoked.
        $mock should_receive something {{a b} {
            expect $a to equal "a"
            expect $b to equal "b"
            return "done"
        }}

        expect [$mock something "a" "b"] to equal "done"
        $mock spec_verify
    }

    it "allows setting expectations on method ensembles" {
        $mock should_receive "parent sub"
        expect [$mock parent sub] to equal ""
        $mock spec_verify
    }

    context "when receiving a block" {
        before each {
            set calls 0
        }

        it "calls the passed block" {
            $mock should_receive "foo" [list {} { variable calls; incr calls } [namespace current]]

            $mock foo

            expect $calls to equal 1
        }

        it "calls the passed block after a similar stub definition" {
            $mock stub "foo" -and_return [list "bar"]
            $mock should_receive "foo" [list {} { variable calls; incr calls } [namespace current]]

            $mock foo

            expect $calls to equal 1
        }
    }
}

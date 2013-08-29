package require "TclOO::ext::autorelease_pool"
package require "TclOO::ext::reference_countable"

describe "AutoreleasePool" {
    describe ".add_object" {
        before each {
            variable object [ReferenceCountable new]
        }

        after each {
            $object release

            AutoreleasePool spec_reset
        }

        it "should complain if called when no pool exists" {
            AutoreleasePool should_receive "current_pool" -and_return [list ""]
            mock_call "::puts" -once -with [list "stderr" [anything]]

            AutoreleasePool add_object $object
        }

        it "adds the object to the currently active pool" {
            set pool [stub "AutoreleasePool"]
            $pool should_receive "add_object" -with [list $object]
            AutoreleasePool should_receive "current_pool" -and_return [list $pool]

            AutoreleasePool add_object $object
        }
    }

    describe "#retain" {
        before each {
            variable pool [AutoreleasePool new]
        }

        after each {
            $pool release
        }

        it "should raise an error" {
            expect {
                $pool retain
            } to raise_error
        }
    }

    describe "#autorelease" {
        before each {
            variable pool [AutoreleasePool new]
        }

        after each {
            $pool release
        }

        it "should raise an error" {
            expect {
                $pool autorelease
            } to raise_error
        }
    }

    describe "#release" {
        before each {
            variable pool [AutoreleasePool new]
            variable object [stub "ReferenceCountable"]
        }

        it "drains the pool and destroys it" {
            $pool add_object $object

            $object should_receive "release" -once

            $pool release
        }

        it "calls #release on an object as many times as it is inside the pool" {
            $pool add_object $object
            $pool add_object $object

            $object should_receive "release" -twice

            $pool release
        }
    }
}

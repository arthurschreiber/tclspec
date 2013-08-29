package require "TclOO::ext::reference_countable"

describe "ReferenceCountable" {
    it "should provide methods for handling refcounts" {
        set object [ReferenceCountable new]
        $object release

        expect [info object isa object $object] to be false

        set object [ReferenceCountable new]
        $object retain
        $object release
        $object release

        expect [info object isa object $object] to be false
    }

    describe "#autorelease" {
        it "puts the object in the current AutoreleasePool, without changing the refcount" {
            set object [ReferenceCountable new]

            AutoreleasePool should_receive "add_object" -with [list $object]
            $object autorelease

            expect [info object isa object $object] to be true
            $object release
        }
    }
}

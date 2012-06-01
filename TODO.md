# TODO

### General

* None of the nx objects that are created are ever destroyed.
  Might not be a good idea, as no memory used will ever be released.

* Better error traces would be nice. In theory, on each top level call to
  ExampleGroup.describe, we could track the currently executing source file,
  then record each (relative) line a nested describe or example block was
  executed on, and from that build a better error trace, that will actually be
  able to pinpoint the exact file and line an error occurred.

  Basically, what we have to do here is to call [info frame -1] inside
  ExampleGroup.describe and see, if the returned dict contains a file and
  a line entry. If it does, we should store these two away. A good idea
  would be to use basically the same way RSpec does it: Each Example and
  ExampleGroup has a MetaData object that stores file and line numbers
  (and more information).

  Using this metadata information, we could build our own stack traces as soon
  as an error happens. We could even try to pinpoint the _exact_ file and line
  an expectation error happened!

* Better support of [info script] - Currently, [info script] will return an
  empty string if executed inside a describe/before/after/it block. That's
  not so nice if you want to access files relative to the currently executing
  spec file. If we correctly track file names for error trace generation, we
  could simply set [info script] to a different value before executing an
  example group instance and reset it afterwards.

### Core

* TclSpec has currently no support for "shared" example groups as in RSpec.
  Something like:

  ```tcl
  shared_examples "collections" {{collection_class} {
    it "is empty when first created" {
      expect [[$collection_class new] empty?] to be_true
    }
  }}

  describe "List" {
    include_examples "collections" List
  }
  
  describe "Dict" {
    include_examples "collections" Dict
  }
  ```

* TclSpec does currently not support "pending" specs:

  ```tcl
  describe "Something" {
    it "should be pending without a block"
    it "should be pending if 'pending' is called in the block" {
      pending; # Should abort here
      ...
    }
    it "should be pending if 'pending' is called in the block" {
      pending "with a message"; # Should abort here
      ...
    }
  }
  ```

* It would be nice, if we could make describe and it blocks take additional
  informations, ala RSpec. Something along the lines of:

  ```tcl
  describe "Something" { type ui } {
      it "does something" { slow true } {
          # ...
      }
  }
  ```

  That way, users could "tag" their specs so only specs with special
  tags can be called. In the above example, that would allow only
  calling e.g. specs for the ui or excluding specs that are slow.

* Colorized output would be very nice.

* Automatic execution of specs is also missing. See `autotest` in Rspec.

### Expectations

* RSpec comes with a DSL that allows a very easy definition of new "expectation methods".
  TclSpec should have something like that, too! :)

### Mocks

* Tcl mocks are missing the ability to set call count expectations (à la `-once`, `-twice`, `-never`).

* Ordered message expectations for tcl and nx mocks would be great:

  ```tcl
  # This should fail if $mock does not receive these two
  # method calls in the correct order.
  $mock should_receive "something" -ordered
  $mock should_receive "something_else" -ordered
  ```

* Better error traces for mocks. Rspec-mocks records the stack trace when
  an expectation is set, so it can later throw an error that appears to be
  coming from that location. This is nice, as it allows to easily identify
  the expectation that failed.
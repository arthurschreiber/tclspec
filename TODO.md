### TODO

asdfasjdöflkja ösl


* None of the nx objects that are created are ever destroyed.
  Might not be a good idea, as no memory used will ever be released.

  I should ask on the nx mailing list what the state of the art of memory
  management in nx is.

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

* It would be nice, if we could make describe and it blocks take additional
  informations, ala RSpec. Something along the lines of:

    describe "Something" { type ui } {
        it "does something" { slow true } {
            # ...
        }
    }

  That way, users could "tag" their specs so only specs with special
  tags can be called. In the above example, that would allow only
  calling e.g. specs for the ui or only specs that are slow.

* Better support of [info script] - Currently, [info script] will return an
  empty string if executed inside a describe/before/after/it block. That's
  not so nice if you want to access files relative to the currently executing
  spec file. If we correctly track file names for error trace generation, we
  could simply set [info script] to a different value before executing an
  example group instance and reset it afterwards.

* Better error traces for mocks. Rspec-mocks records the stack trace when
  an expectation is set, so it can later throw an error that appears to be
  coming from that location. This is nice, as it allows to easily identify
  the expectation that failed.
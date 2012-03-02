### TODO

* None of the nx objects that are created are ever destroyed.
  Might not be a good idea, as no memory used will ever be released.

* Better error traces would be nice. In theory, on each top level call to
  ExampleGroup.describe, we could track the currently executing source file,
  then record each (relative) line a nested describe or example block was
  executed on, and from that build a better error trace, that will actually be
  able to pinpoint the exact file and line an error occurred.

* Better support of [info script] - Currently, [info script] will return an
  empty string if executed inside a describe/before/after/it block. That's
  not so nice if you want to access files relative to the currently executing
  spec file. If we correctly track file names for error trace generation, we
  could simply set [info script] to a different value before executing an
  example group instance and reset it afterwards.
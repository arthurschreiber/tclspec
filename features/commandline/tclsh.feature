Feature: run with tclsh command

  You can use the `tclsh` command to run specs. You just need to require
  the `spec/autorun` package.

  Generally speaking, you're better off using the `tclspec` command, which
  requires `spec/autorun` for you, but some tools only work with the `tclspec`
  command.

  Scenario:
    Given a file named "example_spec.tcl" with:
      """
      # Put tclspec in the package search path
      lappend auto_path [file join [file dirname [info script]] ".." ".."]

      package require spec/autorun

      describe 1 {
          it "is < 2" {
            expect 1 to be < 2
          }
      }
      """
    When I run `tclsh example_spec.tcl`
    Then the output should contain "1 example, 0 failures"
Feature: arbitrary helper procs

  You can define procs in any example group using Tcl's `proc` command or.
  These _helper_ methods are exposed to examples in the group in which they
  are defined and groups nested within that group, but not parent or sibling
  groups.

  Scenario: use a proc defined in the same group
    Given a file named "example_spec.tcl" with:
      """
      describe "an example" {
          proc help { } {
              return "available"
          }

          it "has access to methods defined in its group" {
              expect [help] to equal "available"
          }
      }
      """
    When I run `tclspec example_spec.tcl`
    Then the examples should all pass

  Scenario: use a proc defined in a parent group
    Given a file named "example_spec.tcl" with:
      """
      describe "an example" {
          proc help { } {
              return "available"
          }

          describe "in a nested group" {
              it "has access to methods defined in its parent group" {
                  expect [help] to equal "available"
              }
          }
      }
      """
    When I run `tclspec example_spec.tcl`
    Then the examples should all pass
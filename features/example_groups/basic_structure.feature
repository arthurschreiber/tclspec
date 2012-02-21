Feature: basic structure (describe/it)

  TclSpec is a DSL for creating executable examples of how code is expected to
  behave, organized in groups. It uses the words "describe" and "it" so we can
  express concepts like a conversation:

      "Describe an account when it is first opened."
      "It has a balance of zero."

  The `describe` method creates an example group.  Within the block passed to
  `describe` you can declare nested groups using the `describe` or `context`
  methods, or you can declare examples using the `it` or `specify` methods.

  Under the hood, an example group is a class in which the block passed to
  `describe` or `context` is evaluated. The blocks passed to `it` are evaluated
  in the context of an _instance_ of that class.

  Scenario: one group, one example
    Given a file named "sample_spec.tcl" with:
    """
    describe "something" {
        it "does something" {
        }
    }
    """
    When I run `tclspec sample_spec.tcl -f doc`
    Then the output should contain:
      """
      something
        does something
      """

  Scenario: nested example groups (using context)
    Given a file named "nested_example_groups_spec.tcl" with:
    """
    describe "something" {
        context "in one context" {
            it "does one thing" {
            }
        }
        context "in another context" {
            it "does another thing" {
            }
        }
    }
    """
    When I run `tclspec nested_example_groups_spec.tcl -f doc`
    Then the output should contain:
      """
      something
        in one context
          does one thing
        in another context
          does another thing
      """
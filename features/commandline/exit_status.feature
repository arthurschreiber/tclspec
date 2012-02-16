Feature: exit status

  Scenario: exit with 0 if all examples pass
    Given a file named "ok_spec.tcl" with:
      """
      describe "ok" {
          it "passes" {
          }
      }
      """
    When I run `tclspec ok_spec.tcl`
    Then the exit status should be 0
    And the examples should all pass

  Scenario: exit with 1 when one example fails
    Given a file named "ko_spec.tcl" with:
      """
      describe "KO" {
          it "fails" {
              error "KO"
          }
      }
      """
    When I run `tclspec ko_spec.tcl`
    Then the exit status should be 1
    And the output should contain "1 example, 1 failure"

  Scenario: exit with 1 when a nested examples fails
    Given a file named "nested_ko_spec.tcl" with:
      """
      describe "KO" {
          describe "nested" {
              it "fails" {
                  error "KO"
              }
          }
      }
      """
    When I run `tclspec nested_ko_spec.tcl`
    Then the exit status should be 1
    And the output should contain "1 example, 1 failure"

  Scenario: exit with 0 when no examples are run
    Given a file named "a_no_examples_spec.tcl" with:
      """
      """
    When I run `tclspec a_no_examples_spec.tcl`
    Then the exit status should be 0
    And the output should contain "0 examples"

#  Scenario: exit with 2 when one example fails and --failure-exit-code is 2
#    Given a file named "ko_spec.tcl" with:
#      """
#      describe "KO" {
#          it "fails" {
#              error "KO"
#          }
#      }
#      """
#    When I run `tclspec --failure-exit-code 2 ko_spec.tcl`
#    Then the exit status should be 2
#    And the output should contain "1 example, 1 failure"

  Scenario: exit with tclspec's exit code when an at_exit hook is added upstream
    Given a file named "exit_at_spec.tcl" with:
      """
      package require spec/autorun

      describe "exit 0 at_exit" {
          it "does not interfere with tclspec's exit code" {
              at_exit::at_exit { exit 0 }
              error "asdf"
          }
      }
      """
    When I run `tclspec exit_at_spec.tcl`
    Then the exit status should be 1
    And the output should contain "1 example, 1 failure"
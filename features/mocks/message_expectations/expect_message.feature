Feature: expect a message

  Use should_receive to set an expectation that a receiver should receive a
  message before the example is completed.

  Scenario: expect a message
    Given a file named "spec/account_spec.tcl" with:
      """
      source lib/account.tcl

      describe Account {
          context "when closed" {
              it "logs an account closed message" {
                  set logger [double "logger"]
                  set account [Account new -logger $logger]

                  $logger should_receive "account_closed"

                  $account close
              }

          }
      }
      """
    And a file named "lib/account.tcl" with:
      """
      package require nx

      nx::Class create Account {
          :property logger

          :public method close {} {
              ${:logger} account_closed
          }
      }
      """
    When I run `tclspec spec/account_spec.tcl`
    Then the output should contain "1 example, 0 failures"

  Scenario: expect a message with an argument
    Given a file named "spec/account_spec.tcl" with:
      """
      source lib/account.tcl

      describe Account {
          context "when closed" {
              it "logs an account closed message" {
                  set logger [double "logger"]
                  set account [Account new -logger $logger]

                  $logger should_receive "account_closed" -with [list $account]

                  $account close
              }

          }
      }
      """
    And a file named "lib/account.tcl" with:
      """
      package require nx

      nx::Class create Account {
          :property logger

          :public method close {} {
              ${:logger} account_closed [:]
          }
      }
      """
    When I run `tclspec spec/account_spec.tcl`
    Then the output should contain "1 example, 0 failures"

  Scenario: provide a return value
    Given a file named "message_expectation_spec.tcl" with:
      """
      describe "a message expectation" {
          context "with a return value" {
              context "specified in a block" {
                  it "returns the specified value" {
                      set receiver [double "receiver"]
                      $receiver should_receive "message" {{} {
                          return "return_value"
                      }}

                      expect [$receiver message] to equal "return_value"
                  }
              }

              context "specified with -and_return" {
                  it "returns the specified value" {
                      set receiver [double "receiver"]
                      $receiver should_receive "message" -and_return [list "return_value"]
                      expect [$receiver message] to equal "return_value"
                  }
              }
          }
      }
      """
    When I run `tclspec message_expectation_spec.tcl`
    Then the output should contain "2 examples, 0 failures"
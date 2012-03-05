# TclSpec

Behaviour Driven Development for Tcl

## Overview

TclSpec is a Behaviour Driven Development (BDD) Framework for the Tcl language.

It is based on [RSpec](https://www.relishapp.com/rspec), a BDD Framework for Ruby.

## Prerequisites

 * Tcl 8.5 or higher
 * [Next Scripting Framework](http://next-scripting.org/) 2.0b3 or higher

## Installation

Put the tclspec folder into one of the folders denoted in your Tcl's $auto_path.

## Basic Usage

TclSpec allows you to describe the behaviour of your code using a structure of
`describe` and `it` blocks.

### Basic Structure

```tcl
describe Order {
    it "sums the prices of its line items" {
        set order [Order new]
        $order add_entry [LineItem new -item [Item new -price [Money new -amount 1.11 -currency USD]]]
        $order add_entry [LineItem new -item [Item new -price [Money new -amount 2.22 -currency USD] -quantity 2]]

        expect [$order total] to equal [Money new -amount 5.55 -currency USD]
    }
}
```
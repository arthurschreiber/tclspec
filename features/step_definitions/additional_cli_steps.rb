Then /^the example(?:s)? should(?: all)? pass$/ do
  step %q{the output should contain "0 failures"}
  step %q{the exit status should be 0}
end

Then /^the example should fail$/ do
  step %q{the output should contain "1 failure"}
  step %q{the exit status should not be 0}
end

Then /^the output should contain all of these:$/ do |table|
  table.raw.flatten.each do |string|
    assert_partial_output(string, all_output)
  end
end
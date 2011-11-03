package require XOTcl
namespace import xotcl::*

Class create Example
Example instproc init { description block } {
  my set description $description
  my set block $block
}

Example instproc before { before } {
    my set before $before
}

Example instproc after { after } {
    my set after $after
}

Example instproc execute { } {
    Matcher set eval_level "#[info level]"
    eval [my set before]
    eval [my set block]
    eval [my set after]
    Matcher set eval_level 1
}
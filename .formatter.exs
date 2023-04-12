# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  import_deps: [:typed_struct],
  locals_without_parens: [dump_attribute: 2, dump_tag: 2, load_attribute: 2]
]

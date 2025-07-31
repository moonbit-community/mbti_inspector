// Test for extract.mbt functions

// Test lexicographic_compare function with various cases  
test "lexicographic_compare basic functionality" {
  // Test equal strings
  inspect(lexicographic_compare("hello", "hello"), content="0")
  
  // Test string ordering
  inspect(lexicographic_compare("apple", "banana"), content="-1")
  inspect(lexicographic_compare("banana", "apple"), content="1")
  
  // Test different lengths
  inspect(lexicographic_compare("cat", "catastrophe"), content="-1")
  inspect(lexicographic_compare("catastrophe", "cat"), content="1")
  
  // Test empty strings
  inspect(lexicographic_compare("", ""), content="0")
  inspect(lexicographic_compare("", "a"), content="-1")
  inspect(lexicographic_compare("a", ""), content="1")
  
  // Test case sensitivity  
  inspect(lexicographic_compare("A", "a"), content="-1")
  inspect(lexicographic_compare("a", "A"), content="1")
}

// Test method name sorting as it would appear in MBTI output
test "lexicographic_compare with method names" {
  let methods = ["zip", "copy", "filter_map", "last", "sort", "unzip"]
  let sorted_methods = methods.copy()
  sorted_methods.sort_by(lexicographic_compare)
  inspect(sorted_methods, content="[\"copy\", \"filter_map\", \"last\", \"sort\", \"unzip\", \"zip\"]")
}

// Test split_pkg_from_type function
test "split_pkg_from_type parsing" {
  // Test with package prefix
  let (pkg1, ty1) = split_pkg_from_type("@moonbitlang/core.String")!
  inspect((pkg1, ty1[:]), content="(moonbitlang/core, String)")
  
  // Test without package prefix
  let (pkg2, ty2) = split_pkg_from_type("String")!
  inspect((pkg2, ty2[:]), content="(\"\", String)")
  
  // Test with nested package
  let (pkg3, ty3) = split_pkg_from_type("@myfreess/mbti_inspector.SomeType")!
  inspect((pkg3, ty3[:]), content="(myfreess/mbti_inspector, SomeType)")
}

// Test split_pkg_from_type error cases
test "split_pkg_from_type error handling" {
  // Test invalid format (@ without .)
  let result = try {
    let _ = split_pkg_from_type("@invalidformat")!
    "Should not reach here"
  } catch {
    err => "Caught expected error: \{err}"
  }
  inspect(result.contains("Caught expected error"), content="true")
}
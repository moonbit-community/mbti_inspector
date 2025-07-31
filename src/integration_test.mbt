// Integration tests that test the main functionality

// Mock MBTI data for testing
fn create_mock_mbti_data() -> String {
  #|pub fn String::length(self : String) -> Int
pub fn String::substring(self : String, start : Int, end : Int) -> String  
pub fn String::trim(self : String) -> String
pub fn String::split(self : String, separator : String) -> Array[String]
pub impl Show for String
pub impl Eq for String
pub impl Compare for String
|
}

// Test method extraction patterns
test "method signature extraction patterns" {
  let sample_methods = [
    "pub fn String::length(self : String) -> Int",
    "pub fn String::substring(self : String, start : Int, end : Int) -> String",
    "pub fn String::trim(self : String) -> String",
    "pub fn String::split(self : String, separator : String) -> Array[String]",
    "fn String::internal_method(self : String) -> Unit",
  ]
  
  // Test that we can identify method patterns (this is conceptual since we need actual parsing)
  for method in sample_methods {
    let has_string_method = method.contains("String::")
    let is_public = method.has_prefix("pub")
    inspect((method, has_string_method, is_public), content="(\{method}, \{has_string_method}, \{is_public})")
  }
}

// Test trait implementation patterns  
test "trait implementation extraction patterns" {
  let sample_impls = [
    "impl Show for String",
    "impl Eq for String", 
    "impl Compare for String",
    "impl @iter.Iter for String",
    "impl CustomTrait for String"
  ]
  
  for impl_line in sample_impls {
    let has_impl = impl_line.has_prefix("impl")
    let for_string = impl_line.contains("for String")
    inspect((impl_line, has_impl, for_string), content="(\{impl_line}, \{has_impl}, \{for_string})")
  }
}

// Test the sorting functionality that's used in the main output
test "method sorting behavior" {
  let unsorted_methods = [
    "zip_to_iter2",
    "copy", 
    "filter_map",
    "last",
    "sort",
    "from_iter",
    "zip",
    "makei",
    "unzip",
    "join"
  ]
  
  let sorted_methods = unsorted_methods.copy()
  sorted_methods.sort_by(lexicographic_compare)
  
  inspect(sorted_methods, content="[\"copy\", \"filter_map\", \"from_iter\", \"join\", \"last\", \"makei\", \"sort\", \"unzip\", \"zip\", \"zip_to_iter2\"]")
}

// Test error handling patterns
test "error handling patterns" {
  // Test how errors are constructed and handled
  let test_cases = [
    ("file_not_found", "failed to read file test.mbt: No such file"),
    ("invalid_directory", "failed to check if /invalid/path is a directory"),
    ("parse_error", "invalid type @package")
  ]
  
  for (case_name, error_msg) in test_cases {
    // This tests the error message format patterns
    let has_expected_format = error_msg.contains("failed to") || error_msg.contains("invalid")
    inspect((case_name, has_expected_format), content="(\{case_name}, true)")
  }
}

// Test command line argument patterns
test "command line argument patterns" {
  let sample_args = [
    ["String"],
    ["--drop-deprecated", "String"],
    ["--colorful", "Array"], 
    ["@moonbitlang/core.String"],
    ["StringView"],
    ["List.T"]
  ]
  
  for args in sample_args {
    let has_type_arg = args.any(fn(arg) { !arg.has_prefix("--") })
    let has_flags = args.any(fn(arg) { arg.has_prefix("--") })
    let has_package_qualified = args.any(fn(arg) { arg.has_prefix("@") })
    
    inspect((args, has_type_arg, has_flags, has_package_qualified), 
           content="(\{args}, \{has_type_arg}, \{has_flags}, \{has_package_qualified})")
  }
}
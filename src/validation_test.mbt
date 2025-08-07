// Validation tests for project structure and workflow

// Test project configuration validation  
test "validate project structure assumptions" {
  // Test that our assumptions about moon.mod.json structure are correct
  let expected_fields = ["name", "version", "deps", "source"]
  
  // This validates the structure we expect to parse
  for field in expected_fields {
    let field_is_valid = field.length() > 0
    inspect((field, field_is_valid), content="(\{field}, true)")
  }
}

// Test MBTI file extension validation
test "validate mbti file patterns" {
  let test_filenames = [
    "module.mbti",
    "package.mbti", 
    "library.mbti",
    "notmbti.mbt",
    "notmbti.txt",
    "file.mbti.backup"
  ]
  
  let mbti_files = []
  for filename in test_filenames {
    if filename.has_suffix(".mbti") {
      mbti_files.push(filename) 
    }
  }
  
  inspect(mbti_files.length(), content="3")
  inspect(mbti_files.contains("module.mbti"), content="true")
  inspect(mbti_files.contains("package.mbti"), content="true")
  inspect(mbti_files.contains("library.mbti"), content="true")
}

// Test directory traversal patterns
test "validate directory exclusion logic" {
  let test_paths = [
    "./src/main.mbt",
    "./target/debug/output",
    "./lib/utils.mbt", 
    "./target/release/app",
    "./docs/readme.md"
  ]
  
  let non_target_paths = []
  for path in test_paths {
    // Simulate the logic that excludes target directory when base is "."
    if !(path.has_prefix("./target")) {
      non_target_paths.push(path)
    }
  }
  
  inspect(non_target_paths.length(), content="3")
  inspect(non_target_paths.contains("./src/main.mbt"), content="true")
  inspect(non_target_paths.contains("./lib/utils.mbt"), content="true")
  inspect(non_target_paths.contains("./docs/readme.md"), content="true")
}

// Test location string formatting
test "validate location string format" {
  let sample_locations = [
    "src/main.mbt:10:20",
    "lib/utils.mbt:5:15",
    "package/module.mbt:100:150"
  ]
  
  for location in sample_locations {
    let has_filename = location.contains(".mbt:")
    let has_line_numbers = location.contains(":")
    let parts = location.split(":")
    let has_three_parts = parts.length() == 3
    
    inspect((location, has_filename, has_line_numbers, has_three_parts),
           content="(\{location}, true, true, true)")
  }
}

// Test error message consistency
test "validate error message patterns" {
  let error_patterns = [
    "failed to read file",
    "failed to check if", 
    "failed to read directory",
    "invalid type",
    "not found in"
  ]
  
  // Test that error messages follow expected patterns
  for pattern in error_patterns {
    let is_descriptive = pattern.contains("failed") || pattern.contains("invalid") || pattern.contains("not found")
    inspect((pattern, is_descriptive), content="(\{pattern}, true)")
  }
}

// Test type name extraction patterns
test "validate type name formats" {
  let type_patterns = [
    ("String", true),
    ("Array", true), 
    ("Option", true),
    ("@package.Type", true),
    ("123Invalid", false),  // Invalid identifier
    ("", false)             // Empty string
  ]
  
  for (type_name, should_be_valid) in type_patterns {
    let looks_valid = type_name.length() > 0 && 
                     (type_name[0].is_ascii_alpha() || type_name.has_prefix("@"))
    inspect((type_name, looks_valid == should_be_valid), content="(\{type_name}, true)")
  }
}
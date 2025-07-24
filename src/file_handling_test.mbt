// Tests for file handling and parsing functionality

// Test byte splitting into lines
test "split_bytes functionality" {
  let sample_bytes = "line1\nline2\nline3\n".to_bytes()
  let lines = split_bytes(sample_bytes)!
  
  inspect(lines.length(), content="4")
  inspect(lines[0][:], content="line1")  
  inspect(lines[1][:], content="line2")
  inspect(lines[2][:], content="line3")
  inspect(lines[3][:], content="")  // empty line at the end
}

// Test empty file handling
test "split_bytes with empty content" {
  let empty_bytes = "".to_bytes()
  let lines = split_bytes(empty_bytes)!
  
  inspect(lines.length(), content="1")
  inspect(lines[0][:], content="")
}

// Test single line without newline  
test "split_bytes single line no newline" {
  let single_line_bytes = "single line".to_bytes()
  let lines = split_bytes(single_line_bytes)!
  
  inspect(lines.length(), content="1")
  inspect(lines[0][:], content="single line")
}

// Test multiple empty lines
test "split_bytes with empty lines" {
  let with_empty_lines = "line1\n\nline3\n\n".to_bytes()
  let lines = split_bytes(with_empty_lines)!
  
  inspect(lines.length(), content="5")
  inspect(lines[0][:], content="line1")
  inspect(lines[1][:], content="")
  inspect(lines[2][:], content="line3")
  inspect(lines[3][:], content="")
  inspect(lines[4][:], content="")
}

// Test Unix-style line endings (our implementation uses Unix-style)
test "split_bytes line ending handling" {
  let unix_style = "line1\nline2\n".to_bytes()
  let unix_lines = split_bytes(unix_style)!
  
  inspect(unix_lines.length(), content="3")
  inspect(unix_lines[0][:], content="line1")
  inspect(unix_lines[1][:], content="line2")
  inspect(unix_lines[2][:], content="")
}

// Test source pattern matching for methods
test "method pattern matching" {
  let sample_source_lines = [
    "pub fn String::method1(self) -> Int {",
    "  // implementation", 
    "}",
    "fn String::internal_helper(self) -> Unit {",
    "  // helper code",
    "}",
    "// not a method",
    "let x = 42"
  ]
  
  // Convert strings to string views for testing
  let method_lines = []
  for line in sample_source_lines {
    if line.has_prefix("fn") && line.contains(" String::") {
      method_lines.push(line)
    }
  }
  
  inspect(method_lines.length(), content="2")
  inspect(method_lines[0].contains("method1"), content="true")
  inspect(method_lines[1].contains("internal_helper"), content="true")
}

// Test trait implementation pattern matching
test "impl pattern matching" {
  let sample_source_lines = [
    "impl Show for String {",
    "  fn show(self) -> String {",
    "    self",
    "  }",
    "}",
    "impl @trait.Custom for String {",
    "  // custom implementation",
    "}",
    "// not an impl",
    "struct Point { x: Int, y: Int }"
  ]
  
  let impl_lines = []
  for line in sample_source_lines {
    if line.has_prefix("impl") && line.contains(" for String") {
      impl_lines.push(line)
    }
  }
  
  inspect(impl_lines.length(), content="2")
  inspect(impl_lines[0].contains("Show"), content="true")
  inspect(impl_lines[1].contains("@trait.Custom"), content="true")
}
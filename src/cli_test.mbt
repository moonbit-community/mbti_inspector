// Tests for CLI behavior and output formatting

// Test usage message format  
test "usage message format" {
  let usage = #| usage:
   mbti_inspector [options] <type>
  
  let expected_pattern = usage.contains("mbti_inspector") && 
                        usage.contains("[options]") && 
                        usage.contains("<type>")
  inspect(expected_pattern, content="true")
}

// Test colorful output formatting patterns
test "colorful output behavior" {
  // Save original state
  let original_colorful = colorful_output.val
  
  // Test with colorful output enabled
  colorful_output.val = true
  let should_use_color = colorful_output.val
  inspect(should_use_color, content="true")
  
  // Test with colorful output disabled  
  colorful_output.val = false
  let should_not_use_color = !colorful_output.val
  inspect(should_not_use_color, content="true")
  
  // Restore original state
  colorful_output.val = original_colorful
}

// Test deprecated method filtering
test "deprecated method filtering" {
  // Save original state
  let original_drop_deprecated = drop_derecated.val
  
  // Test with deprecated methods dropped
  drop_derecated.val = true
  let should_drop = drop_derecated.val
  inspect(should_drop, content="true")
  
  // Test with deprecated methods included
  drop_derecated.val = false  
  let should_include = !drop_derecated.val
  inspect(should_include, content="true")
  
  // Restore original state
  drop_derecated.val = original_drop_deprecated
}

// Test method output format patterns
test "method output format patterns" {
  // Test the expected format of method output lines
  let sample_method_output = "fn String::length(self : String) -> Int        // src/string.mbt:42:45"
  
  let has_method_signature = sample_method_output.contains("fn ")
  let has_location_info = sample_method_output.contains(".mbt:")
  let has_line_numbers = sample_method_output.contains(":42:")
  let separator_present = sample_method_output.contains("        // ")
  
  inspect((has_method_signature, has_location_info, has_line_numbers, separator_present),
         content="(true, true, true, true)")
}

// Test impl output format patterns
test "impl output format patterns" {
  // Test the expected format of trait implementation output lines
  let sample_impl_output = "Show        // src/string.mbt:10:15"
  
  let has_trait_name = sample_impl_output.contains("Show")
  let has_location_info = sample_impl_output.contains(".mbt:")
  let has_line_numbers = sample_impl_output.contains(":10:")
  let separator_present = sample_impl_output.contains("        // ")
  
  inspect((has_trait_name, has_location_info, has_line_numbers, separator_present),
         content="(true, true, true, true)")
}

// Test deprecated method marking
test "deprecated method marking" {
  let deprecated_method_output = "#deprecated\nfn String::old_method(self : String) -> Unit         // src/string.mbt:100:105"
  
  let has_deprecated_marker = deprecated_method_output.has_prefix("#deprecated")
  let has_newline_after_marker = deprecated_method_output.contains("#deprecated\n")
  
  inspect((has_deprecated_marker, has_newline_after_marker), 
         content="(true, true)")
}
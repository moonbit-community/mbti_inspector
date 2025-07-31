// Test for config.mbt

test "config default values" {
  // Test that config variables have correct default values
  inspect(drop_derecated.val, content="false")
  inspect(colorful_output.val, content="false")
}

test "config value modification" {
  // Save original values
  let original_drop_deprecated = drop_derecated.val
  let original_colorful = colorful_output.val
  
  // Modify values
  drop_derecated.val = true
  colorful_output.val = true
  
  // Check modifications
  inspect(drop_derecated.val, content="true")
  inspect(colorful_output.val, content="true")
  
  // Restore original values
  drop_derecated.val = original_drop_deprecated
  colorful_output.val = original_colorful
  
  // Verify restoration
  inspect(drop_derecated.val, content="false")
  inspect(colorful_output.val, content="false")
}
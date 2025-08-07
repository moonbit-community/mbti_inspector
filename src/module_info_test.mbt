// Test for module_info.mbt functions

// Test get_src_location function with mock JSON data
test "get_src_location with source field" {
  let mock_json_with_source = @json.parse(#|{"source": "custom_src"}|)!
  let src = get_src_location(mock_json_with_source)
  inspect(src, content="custom_src")
}

test "get_src_location without source field" {
  let mock_json_without_source = @json.parse(#|{"name": "test"}|)!
  let src = get_src_location(mock_json_without_source)
  inspect(src, content=".")
}

test "get_src_location with null source" {
  let mock_json_with_null_source = @json.parse(#|{"source": null}|)!
  let src = get_src_location(mock_json_with_null_source)
  inspect(src, content=".")
}

// Test with the actual project's moon.mod.json structure
test "get_src_location with realistic module structure" {
  let realistic_json = @json.parse(#|{
    "name": "myfreess/mbti_inspector",
    "version": "0.1.0",
    "source": "src",
    "deps": {}
  }|)!
  let src = get_src_location(realistic_json)
  inspect(src, content="src")
}
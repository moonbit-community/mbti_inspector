fn load_module_info() -> Json raise Error {
  let text = @fs.read_file_to_string("moon.mod.json")
  @json.parse(text)
}

fn get_module_name(module_info : Json) -> String raise Error {
  if module_info.value("name") is Some(name){
    return name.as_string().unwrap()
  } else {
    fail("Module name not found in module info")
  }
}

fn get_src_location(module_info : Json) -> String {
  if module_info.value("source") is Some(src) {
    return src.as_string().unwrap()
  } else {
    return "."
  }
}


test {
  let module_info = load_module_info()
  let name = get_module_name(module_info)
  let src_location = get_src_location(module_info)
  inspect(name, content="myfreess/mbti_inspector")
  inspect(src_location, content="src/")
}
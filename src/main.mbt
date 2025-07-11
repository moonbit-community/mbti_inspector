///|
fn main {
  guard @sys.get_cli_args() is [_, ty] else {
    println("Usage: mbti_inspector <type>\n")
    panic()
  }
  try {
    let (method_table, impl_table) = read_method_set_from_type(ty)
    for path, methods in method_table {
      for method_with_place in methods {
        println("\{method_with_place.1}        // \{method_with_place.2}")
      }
      for impl_with_place in impl_table.get(path).unwrap() {
        println("\{impl_with_place.1}        // \{impl_with_place.2}")
      }
    }
  } catch {
    err => println("Error: \{err}")
  }
}

///|
fn main {
  guard @sys.get_cli_args() is [_, ty] else {
    println("Usage: mbti_inspector <type>\n")
    panic()
  }
  try {
    for method_ in read_method_set_from_type(ty) {
      println(method_)
    }
  } catch {
    err => println("Error: \{err}")
  }
}

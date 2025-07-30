///|
fn main {
  let argv = @sys.get_cli_args()[1:].to_array()
  let usage =
    #| usage:
    #|   mbti_inspector [options] <type>
  let types = []
  @ArgParser.parse(
    [
      (
        "--drop-deprecated",
        "-d",
        Set(drop_derecated),
        "drop deprecated methods",
      ),
      ("--colorful", "-c", Set(colorful_output), "use colorful output"),
    ],
    fn(ty) { types.push(ty) },
    usage,
    argv,
  )
  guard types is [ty, ..] else {
    println(usage)
    println("Error: <type> argument not found")
    return
  }
  try {
    let empty = @chalk.chalk()
    let bold = @chalk.chalk().modifier(Bold)
    let dim = @chalk.chalk().modifier(Dim)
    let blue = @chalk.chalk().color(Blue).modifier(Bold)
    let (method_table, impl_table) = read_method_set_from_type(ty)
    for path, methods in method_table {
      for method_with_place in methods {
        let render = if method_with_place.1.has_prefix("#deprecated") {
          dim
        } else {
          bold
        }
        let render = if colorful_output.val { render } else { empty }
        println(
          render.render(
            "\{method_with_place.1}        // \{method_with_place.2}",
          ),
        )
      }
      for impl_with_place in impl_table.get(path).unwrap() {
        let render = if colorful_output.val { blue } else { empty }
        println(
          render.render("\{impl_with_place.1}        // \{impl_with_place.2}"),
        )
      }
    }
  } catch {
    err => println("Error: \{err}")
  }
}

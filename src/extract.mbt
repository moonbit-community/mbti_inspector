///|
/// 
fn is_directory(path : String, loc~ : SourceLoc = _) -> Bool raise Error {
  @fs.is_dir(path) catch {
    err => fail("failed to check if \{path} is a directory: \{err}", loc~)
  }
}

fn get_mbti_path_set_from_base(base : String) -> Array[String] raise Error {
  let mbti_set = Array::new(capacity = 20)
  let path_set = @fs.read_dir(base) catch {
    err => fail("failed to read directory \{base}: \{err}")
  }
  let path_set = {
    let q = @queue.new()
    for path in path_set {
      // ignore target directory
      if !(base == "." && path == "target") {
        q.push(base + "/" + path)
      }
    } else {
      q
    }
  }
  while not(path_set.is_empty()) {
    let path = path_set.unsafe_pop()
    if not(@fs.path_exists(path)) {
      println("invalid path construct by mbti_inspector internal: \{path}")
    }
    if is_directory(path) {
      let new_path_set = @fs.read_dir(path) catch {
        err => fail("failed to read directory \{base}: \{err}")
     }
      for new_path in new_path_set {
        path_set.push(path + "/" + new_path)
      }
    } else {
      if path.has_suffix(".mbti") {
        mbti_set.push(path)
      }
    }
  } else {
    return mbti_set
  }
}

// Lexicographic order compare of String

fn lexicographic_compare(x : String, y : String) -> Int {
  let x_len = x.length()
  let y_len = y.length()
  let min_len = if x_len < y_len { x_len } else { y_len }
  for i in 0..<min_len {
    let cmp = x.charcode_at(i).compare(y.charcode_at(i))
    if cmp != 0 {
      return cmp
    }
  }
  return x_len.compare(y_len)
}

test {
  let arr = [
    "copy",
    "filter_map",
    "from_iter",
    "join",
    "last",
    "makei",
    "push_iter",
    "shuffle",
    "shuffle_in_place",
    "sort",
    "sort_by",
    "sort_by_key",
    "unzip",
    "zip",
    "zip_to_iter2"
  ]
  arr.sort_by(lexicographic_compare)
  inspect(arr, content=(
    #|["copy", "filter_map", "from_iter", "join", "last", "makei", "push_iter", "shuffle", "shuffle_in_place", "sort", "sort_by", "sort_by_key", "unzip", "zip", "zip_to_iter2"]

  ))
}

fn extract_type_name(ty : @ast.Type) -> String? {
  match ty {
    TName(constr_id, _, ..) => 
      match constr_id.id {
        Ident(name~) => Some(name)
        _ => None
      }
    TOption(_) => Some("Option")
    _ => None
  }
}

// (method_name, source, location)
typealias @hashmap.T[String, Array[(String, @string.View, String)]] as MethodTable
// (trait_name, source, location)
typealias @hashmap.T[String, Array[(String, @string.View, String)]] as ImplTable

fn read_method_set_from_type(ty : String) -> (MethodTable, ImplTable) raise Error {
  let (pkg, ty) = split_pkg_from_type(ty)
  let mbti_set = read_mbti(pkg)
  fn get_loc_from_ty(ty : @ast.Type) -> @ast.Location {
    match ty {
      TAny(loc) => loc
      TArrow(loc~, ..) => loc
      TTuple(_, loc~) => loc
      TName(_, _, loc~) => loc
      TOption(_, loc~, ..) => loc
      TObject({loc, ..}) => loc
    }
  }
  fn get_loc_from_err(err : @ast.ErrorType) -> @ast.Location? {
    match err {
      ErrorType(ty~, ..) => Some(get_loc_from_ty(ty))
      DefaultErrorType(loc, ..) => Some(loc)
      NoErrorType => None
      MaybeError(_) => None
    }
  }
  let method_table = @hashmap.new(capacity = mbti_set.length())
  let impl_table = @hashmap.new(capacity = mbti_set.length())
  for mbti_with_source in mbti_set {
    let (path, source, mbti) = mbti_with_source
    method_table[path] = Array::new(capacity = 40)
    impl_table[path] = Array::new(capacity = 20)
    let source = split_bytes(source)
    for sig in mbti.sigs {
      if sig.0 is Func(fnsig) && fnsig.type_name is Some(ty_name) && ty_name.name[:] == ty {
        if drop_derecated.val && fnsig.attr.any(a => a.0 == "deprecated") {
          continue
        }
        let mut fn_line = find_method_from_source(path~, source, type_name = ty_name.name, fn_name = fnsig.name.name)
        if fnsig.attr.any(a => a.0 == "deprecated") {
          fn_line = "[deprecated] \{fn_line} "
        }
        let location = {
          let filename = if fnsig.type_params is More(type_param, ..) { 
            type_param.name.loc.start.fname
          } else {
            fnsig.name.loc.start.fname
          }
          let start_line = if fnsig.type_params is More(type_param, ..) {
            type_param.name.loc.start.lnum
          } else {
            fnsig.name.loc.start.lnum
          }
          let end_line = if get_loc_from_err(fnsig.return_.1) is Some(loc) {
            loc.end.lnum
          } else {
            let loc = get_loc_from_ty(fnsig.return_.0)
            loc.end.lnum
          }
          "\{filename}:\{start_line}:\{end_line}"
        }
        method_table.get(path).unwrap().push((fnsig.name.name, fn_line, location))
      }
      if sig.0 is Impl(Trait(type_~, trait_name~, ..)) && extract_type_name(type_) is Some(ty_name) && ty_name[:] == ty {
        let traitname = match trait_name.name {
          Ident(name~) => name
          Qualified(pkg~, name~) => "@\{pkg}.\{name}"
        }
        let impl_line = find_impl_from_source(path~, source, type_name = ty_name, trait_name = traitname)
        let location = {
          let filename = trait_name.loc.start.fname
          let start_line = trait_name.loc.start.lnum
          let end_line = get_loc_from_ty(type_).end.lnum
          "\{filename}:\{start_line}:\{end_line}"
        }
        impl_table.get(path).unwrap().push((traitname, impl_line, location))
      }
    }
  } else {
    for _, methods in method_table {
      methods.sort_by(fn (x, y) { lexicographic_compare(x.0, y.0) })
    } else {
        return (method_table, impl_table)
    }
  }
}


fn split_bytes(bytes : Bytes) -> Array[@string.View] raise Error {
  let source = @encoding.decoder(UTF8).decode(bytes)
  source.split("\n").collect()
}

fn find_method_from_source(path~ : String, source : Array[@string.View], type_name~ : String, fn_name~ : String) -> @string.View raise Error{
  let method_name = " \{type_name}::\{fn_name}("
  for line in source {
    if line.has_prefix("fn") && line.contains(method_name) {
      return line
    }
  } else {
    fail("impossible: \{method_name} not found in \{path}")
  }
}

fn find_impl_from_source(path~ : String, source : Array[@string.View], type_name~ : String, trait_name~ : String) -> @string.View raise Error {
  for line in source {
    if line.has_prefix("impl") && line.contains("\{trait_name} for \{type_name}") {
      return line
    }
  } else {
    fail("impossible: impl \{trait_name} for \{type_name} not found in \{path}")
  }
}

fn split_pkg_from_type(ty : String) -> (String, @string.View) raise Error{
  match ty[:] {
    ['@', .. rest] => {
      let buf = StringBuilder::new()
      loop rest {
        [] => fail("invalid type \{ty}")
        ['.', .. rest] => (buf.to_string(), rest)
        [ch, .. rest] => {
          buf.write_char(ch)
          continue rest
        }
      }
    }
    _ => ("", ty)
  }
}

fn read_mbti(pkg : String) -> Array[(String, Bytes, Mbti)] raise Error {
  let module_info = load_module_info()
  let base = get_src_location(module_info) + (if pkg.is_empty() { "" } else { "/" + pkg })
  let paths = get_mbti_path_set_from_base(base)
  let mbti_set = Array::new(capacity = paths.length())
  for path in paths {
    let bytes = @fs.read_file_to_bytes(path) catch {
      @fs.IOError(err) => {
        fail("failed to read file \{path}: \{err}")
      }
      err => raise err
    }
    mbti_set.push((path, bytes, read_mbti_from_bytes(bytes, name = path)))
  } else {
    return mbti_set
  }
}


fn read_mbti_from_bytes(bytes : Bytes, name~ : String) -> Mbti raise ParseError {
  @lexer.tokens_from_bytes(bytes, comment=false, name~).tokens.filter(fn(triple) {
    not(triple.0 is (NEWLINE | COMMENT(_)))
  })
  |> @mbti_parser.mbti()
}


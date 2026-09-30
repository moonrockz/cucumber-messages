///|
/// Raise a decode error when `value` is outside `min..=max`.
fn check_int_range(
  value : Int,
  path : @json.JsonPath,
  min~ : Int,
  max~ : Int,
) -> Unit raise @json.JsonDecodeError {
  guard value >= min && value <= max else {
    raise @json.JsonDecodeError(
      (path, "expected an integer in \{min}..=\{max}, got \{value}"),
    )
  }
}

///|
/// Raise a decode error when `value` is below `min`.
fn check_int_min(
  value : Int,
  path : @json.JsonPath,
  min~ : Int,
) -> Unit raise @json.JsonDecodeError {
  guard value >= min else {
    raise @json.JsonDecodeError(
      (path, "expected an integer >= \{min}, got \{value}"),
    )
  }
}

///|
/// Decode a required array member that the schema marks `minItems: 1`.
fn[T : @json.FromJson] non_empty_array_field(
  obj : Map[String, Json],
  key : String,
  path : @json.JsonPath,
) -> Array[T] raise @json.JsonDecodeError {
  let items : Array[T] = required_field(obj, key, path)
  guard items.length() > 0 else {
    raise @json.JsonDecodeError(
      (path.add_key(key), "expected at least one item"),
    )
  }
  items
}

///|
/// Decode a required integer member with a schema minimum.
fn int_field_min(
  obj : Map[String, Json],
  key : String,
  path : @json.JsonPath,
  min~ : Int,
) -> Int raise @json.JsonDecodeError {
  let value : Int = required_field(obj, key, path)
  check_int_min(value, path.add_key(key), min~)
  value
}

///|
/// Decode an optional integer member with a schema minimum.
fn optional_int_field_min(
  obj : Map[String, Json],
  key : String,
  path : @json.JsonPath,
  min~ : Int,
) -> Int? raise @json.JsonDecodeError {
  let value : Int? = optional_field(obj, key, path)
  if value is Some(v) {
    check_int_min(v, path.add_key(key), min~)
  }
  value
}

///|
/// Raise unless `json` is an object; return its members.
fn expect_object(
  json : Json,
  path : @json.JsonPath,
  type_name : String,
) -> Map[String, Json] raise @json.JsonDecodeError {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "\{type_name}::from_json: expected object"),
    )
  }
  obj
}

///|
/// Decode the object member `key`, or raise when it is absent.
fn[T : @json.FromJson] required_field(
  obj : Map[String, Json],
  key : String,
  path : @json.JsonPath,
) -> T raise @json.JsonDecodeError {
  guard obj.get(key) is Some(value) else {
    raise @json.JsonDecodeError((path, "Missing field \{key}"))
  }
  @json.from_json(value, path=path.add_key(key))
}

///|
/// Decode the object member `key`; absent or `null` gives `None`.
fn[T : @json.FromJson] optional_field(
  obj : Map[String, Json],
  key : String,
  path : @json.JsonPath,
) -> T? raise @json.JsonDecodeError {
  match obj.get(key) {
    None | Some(Null) => None
    Some(value) => Some(@json.from_json(value, path=path.add_key(key)))
  }
}

///|
/// Decode an optional `argumentIndex` (schema range 1..=2).
fn argument_index_field(
  obj : Map[String, Json],
  path : @json.JsonPath,
) -> Int? raise @json.JsonDecodeError {
  let index : Int? = optional_field(obj, "argumentIndex", path)
  if index is Some(i) {
    check_int_range(i, path.add_key("argumentIndex"), min=1, max=2)
  }
  index
}

///|
fn decode_fails(label : String, f : () -> Unit raise) -> Unit raise {
  let failed = try f() catch {
    _ => true
  } noraise {
    _ => false
  }
  assert_true(failed, msg="accepted \{label}")
}

///|
test "schema minimums and minItems are enforced" {
  let cases : Array[(String, () -> Unit raise)] = [
    (
      "Location.line 0",
      () => ignore((@json.from_json(@json.parse("{\"line\":0}")) : Location)),
    ),
    (
      "Location.column 0",
      () => {
        ignore(
          (@json.from_json(@json.parse("{\"line\":1,\"column\":0}")) : Location),
        )
      },
    ),
    (
      "Group.start -1",
      () => ignore((@json.from_json(@json.parse("{\"start\":-1}")) : Group)),
    ),
    (
      "TestCaseStarted.attempt -1",
      () => {
        ignore(
          (
            @json.from_json(
              @json.parse(
                "{\"attempt\":-1,\"id\":\"i\",\"testCaseId\":\"t\",\"timestamp\":{\"seconds\":1,\"nanos\":0}}",
              ),
            ) : TestCaseStarted),
        )
      },
    ),
    (
      "ParameterType.regularExpressions []",
      () => {
        ignore(
          (
            @json.from_json(
              @json.parse(
                "{\"id\":\"i\",\"name\":\"n\",\"preferForRegularExpressionMatch\":false,\"regularExpressions\":[],\"useForSnippets\":true}",
              ),
            ) : ParameterType),
        )
      },
    ),
    (
      "Pickle.astNodeIds []",
      () => {
        ignore(
          (
            @json.from_json(
              @json.parse(
                "{\"id\":\"p\",\"uri\":\"u\",\"name\":\"n\",\"language\":\"en\",\"steps\":[],\"tags\":[],\"astNodeIds\":[]}",
              ),
            ) : Pickle),
        )
      },
    ),
    (
      "PickleStep.astNodeIds []",
      () => {
        ignore(
          (
            @json.from_json(
              @json.parse("{\"id\":\"s\",\"text\":\"t\",\"astNodeIds\":[]}"),
            ) : PickleStep),
        )
      },
    ),
    (
      "PickleTableRow.cells []",
      () => {
        ignore(
          (@json.from_json(@json.parse("{\"cells\":[]}")) : PickleTableRow),
        )
      },
    ),
    (
      "Suggestion.snippets []",
      () => {
        ignore(
          (
            @json.from_json(
              @json.parse(
                "{\"id\":\"i\",\"pickleStepId\":\"p\",\"snippets\":[]}",
              ),
            ) : Suggestion),
        )
      },
    ),
  ]
  for case_ in cases {
    decode_fails(case_.0, case_.1)
  }
}

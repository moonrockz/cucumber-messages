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

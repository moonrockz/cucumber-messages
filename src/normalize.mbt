///|
/// Prepare an envelope's JSON for decoding.
///
/// - Object members whose value is `null` are removed, so an explicit `null`
///   on an optional field decodes as `None` in every message type. A `null`
///   on a required field then reports the field as missing.
/// - Every number in the protocol schema is an integer, so a number with a
///   fractional part raises an error instead of being truncated.
fn normalize_envelope_json(
  json : Json,
  path : @json.JsonPath,
) -> Json raise @json.JsonDecodeError {
  match json {
    Object(obj) => {
      let out : Map[String, Json] = Map([], capacity=obj.length())
      for key, value in obj {
        if value is Null {
          continue
        }
        out[key] = normalize_envelope_json(value, path.add_key(key))
      }
      Json::object(out)
    }
    Array(items) => {
      let out : Array[Json] = Array(capacity=items.length())
      for i, item in items {
        out.push(normalize_envelope_json(item, path.add_index(i)))
      }
      Json::array(out)
    }
    Number(n, ..) if n != n.floor() =>
      raise @json.JsonDecodeError((path, "expected an integer, got \{n}"))
    _ => json
  }
}

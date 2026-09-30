///|
/// Prepare an envelope's JSON for decoding.
///
/// Object members whose value is `null` are removed, so an explicit `null`
/// on an optional field decodes as `None` in every message type. A `null`
/// on a required field then reports the field as missing.
fn normalize_envelope_json(json : Json) -> Json {
  match json {
    Object(obj) => {
      let out : Map[String, Json] = Map([], capacity=obj.length())
      for key, value in obj {
        if value is Null {
          continue
        }
        out[key] = normalize_envelope_json(value)
      }
      Json::object(out)
    }
    Array(items) => Json::array(items.map(normalize_envelope_json))
    _ => json
  }
}

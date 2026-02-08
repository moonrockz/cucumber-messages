///|
/// Exception: simplified exception (type, optional message and stackTrace).
pub struct Exception {
  type_ : String
  message : String?
  stackTrace : String?
}

///|
pub impl @json.FromJson for Exception with from_json(json, path) {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Exception::from_json: expected object"))
  }
  let type_ = match obj.get("type") {
    Some(v) => @json.from_json(v, path=path.add_key("type"))
    None =>
      raise @json.JsonDecodeError((path, "Exception::from_json: missing type"))
  }
  let message = match obj.get("message") {
    Some(Null) | None => None
    Some(v) => Some(@json.from_json(v, path=path.add_key("message")))
  }
  let stackTrace = match obj.get("stackTrace") {
    Some(Null) | None => None
    Some(v) => Some(@json.from_json(v, path=path.add_key("stackTrace")))
  }
  Exception::{ type_, message, stackTrace }
}

///|
pub impl ToJson for Exception with to_json(self) {
  let o : Map[String, Json] = { "type": self.type_.to_json() }
  match self.message {
    Some(m) => o.set("message", m.to_json())
    None => ()
  }
  match self.stackTrace {
    Some(st) => o.set("stackTrace", st.to_json())
    None => ()
  }
  o.to_json()
}

///|
test "exception roundtrip" {
  let raw = "{\"type\":\"RuntimeError\",\"message\":\"oops\"}"
  let json = @json.parse(raw)
  let exc : Exception = @json.from_json(json)
  assert_eq(exc.type_, "RuntimeError")
  assert_eq(exc.message, Some("oops"))
  assert_eq(exc.stackTrace, None)
  let back : Exception = @json.from_json(exc.to_json())
  assert_eq(back.type_, exc.type_)
  assert_eq(back.message, Some("oops"))
  assert_eq(back.stackTrace, None)
}

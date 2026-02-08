///|
/// Product: name and optional version (Meta sub-type).
pub struct Product {
  name : String
  version : String?
} derive(ToJson, FromJson)

///|
/// Git: remote, revision, optional branch and tag (Meta sub-type).
pub struct Git {
  remote : String
  revision : String
  branch : String?
  tag : String?
} derive(ToJson, FromJson)

///|
/// Ci: CI environment (Meta sub-type).
pub struct Ci {
  name : String
  url : String?
  buildNumber : String?
  git : Git?
} derive(ToJson, FromJson)

///|
/// Meta: protocol metadata (protocolVersion, implementation, runtime, os, cpu, optional ci).
pub struct Meta {
  protocolVersion : String
  implementation : Product
  runtime : Product
  os : Product
  cpu : Product
  ci : Ci?
} derive(ToJson, FromJson)

///|
test "meta decode and roundtrip" {
  let raw = "{\"protocolVersion\":\"27.0.0\",\"implementation\":{\"name\":\"cucumber-moonbit\"},\"runtime\":{\"name\":\"moonbit\"},\"os\":{\"name\":\"linux\"},\"cpu\":{\"name\":\"amd64\"}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let meta : Meta = @json.from_json(json) catch { _ => panic() }
  assert_eq(meta.protocolVersion, "27.0.0")
  assert_eq(meta.implementation.name, "cucumber-moonbit")
  assert_eq(meta.runtime.name, "moonbit")
  let json2 = meta.to_json()
  let back : Meta = @json.from_json(json2) catch { _ => panic() }
  assert_eq(back.protocolVersion, meta.protocolVersion)
  assert_eq(back.implementation.name, meta.implementation.name)
}

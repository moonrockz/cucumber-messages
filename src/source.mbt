///|
/// Source: a source file (uri, data, mediaType).
pub struct Source {
  uri : String
  data : String
  mediaType : SourceMediaType
} derive(ToJson, FromJson)

///|
/// JavaMethod: for SourceReference (Java glue).
pub struct JavaMethod {
  className : String
  methodName : String
  methodParameterTypes : Array[String]
} derive(ToJson, FromJson)

///|
/// JavaStackTraceElement: for SourceReference.
pub struct JavaStackTraceElement {
  className : String
  fileName : String
  methodName : String
} derive(ToJson, FromJson)

///|
/// SourceReference: points to a Source and optional Location (or Java method/stack).
pub struct SourceReference {
  uri : String?
  javaMethod : JavaMethod?
  javaStackTraceElement : JavaStackTraceElement?
  location : Location?
} derive(ToJson, FromJson)

///|
/// ParseError: parse error with source reference and message.
pub struct ParseError {
  source : SourceReference
  message : String
} derive(ToJson, FromJson)

///|
test "source roundtrip" {
  let raw = "{\"uri\":\"file.feature\",\"data\":\"Feature: x\",\"mediaType\":\"text/x.cucumber.gherkin+plain\"}"
  let json = @json.parse(raw) catch { _ => panic() }
  let src : Source = @json.from_json(json) catch { _ => panic() }
  assert_eq(src.uri, "file.feature")
  assert_eq(src.data, "Feature: x")
  match src.mediaType {
    GherkinPlain => ()
    _ => panic()
  }
  let back : Source = @json.from_json(src.to_json()) catch { _ => panic() }
  assert_eq(back.uri, src.uri)
}

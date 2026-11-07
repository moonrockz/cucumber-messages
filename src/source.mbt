///|
/// Source: a source file (uri, data, mediaType).
#derive(ToJson, FromJson)
pub struct Source {
  uri : String
  data : String
  mediaType : SourceMediaType
}

///|
/// JavaMethod: for SourceReference (Java glue).
#derive(ToJson, FromJson)
pub struct JavaMethod {
  className : String
  methodName : String
  methodParameterTypes : Array[String]
}

///|
/// JavaStackTraceElement: for SourceReference.
#derive(ToJson, FromJson)
pub struct JavaStackTraceElement {
  className : String
  fileName : String
  methodName : String
}

///|
/// SourceReference: points to a Source and optional Location (or Java method/stack).
#derive(ToJson, FromJson)
pub struct SourceReference {
  uri : String?
  javaMethod : JavaMethod?
  javaStackTraceElement : JavaStackTraceElement?
  location : Location?
}

///|
/// ParseError: parse error with source reference and message.
#derive(ToJson, FromJson)
pub struct ParseError {
  source : SourceReference
  message : String
}

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

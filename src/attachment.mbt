///|
/// AttachmentContentEncoding: encoding of attachment body.
pub enum AttachmentContentEncoding {
  Identity
  Base64
}

///|
pub impl @json.FromJson for AttachmentContentEncoding with from_json(json, path) {
  guard json is String(s) else {
    raise @json.JsonDecodeError(
      (path, "AttachmentContentEncoding::from_json: expected string"),
    )
  }
  match s {
    "IDENTITY" => Identity
    "BASE64" => Base64
    _ =>
      raise @json.JsonDecodeError(
        (
          path, "AttachmentContentEncoding::from_json: expected IDENTITY or BASE64",
        ),
      )
  }
}

///|
pub impl ToJson for AttachmentContentEncoding with to_json(self) {
  match self {
    Identity => "IDENTITY".to_json()
    Base64 => "BASE64".to_json()
  }
}

///|
/// Attachment: embedded test artifact.
pub struct Attachment {
  body : String
  contentEncoding : AttachmentContentEncoding
  mediaType : String
  fileName : String?
  source : Source?
  testCaseStartedId : String?
  testStepId : String?
  url : String?
  testRunStartedId : String?
  testRunHookStartedId : String?
  timestamp : Timestamp?
} derive(ToJson, FromJson)

///|
/// ExternalAttachment: linked test artifact.
pub struct ExternalAttachment {
  url : String
  mediaType : String
  testCaseStartedId : String?
  testStepId : String?
  testRunHookStartedId : String?
  timestamp : Timestamp?
} derive(ToJson, FromJson)

///|
test "attachment content encoding roundtrip" {
  let json = @json.parse("\"IDENTITY\"") catch { _ => panic() }
  let enc : AttachmentContentEncoding = @json.from_json(json) catch {
    _ => panic()
  }
  match enc {
    Identity => ()
    _ => panic()
  }
  let json2 = @json.parse("\"BASE64\"") catch { _ => panic() }
  let enc2 : AttachmentContentEncoding = @json.from_json(json2) catch {
    _ => panic()
  }
  match enc2 {
    Base64 => ()
    _ => panic()
  }
  assert_eq(enc.to_json().stringify(), "\"IDENTITY\"")
  assert_eq(enc2.to_json().stringify(), "\"BASE64\"")
}

///|
test "attachment roundtrip" {
  let raw = "{\"body\":\"hello\",\"contentEncoding\":\"IDENTITY\",\"mediaType\":\"text/plain\"}"
  let json = @json.parse(raw) catch { _ => panic() }
  let att : Attachment = @json.from_json(json) catch { _ => panic() }
  assert_eq(att.body, "hello")
  assert_eq(att.mediaType, "text/plain")
  match att.contentEncoding {
    Identity => ()
    _ => panic()
  }
  let back : Attachment = @json.from_json(att.to_json()) catch { _ => panic() }
  assert_eq(back.body, att.body)
}

///|
test "external attachment roundtrip" {
  let raw = "{\"url\":\"https://example.com/img.png\",\"mediaType\":\"image/png\"}"
  let json = @json.parse(raw) catch { _ => panic() }
  let ext : ExternalAttachment = @json.from_json(json) catch { _ => panic() }
  assert_eq(ext.url, "https://example.com/img.png")
  let back : ExternalAttachment = @json.from_json(ext.to_json()) catch {
    _ => panic()
  }
  assert_eq(back.url, ext.url)
}

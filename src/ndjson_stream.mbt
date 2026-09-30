///|
/// Incremental NDJSON reader. Give it input one line at a time with
/// `read_line`, or in chunks of any size with `feed`; it keeps track of
/// line numbers so errors name the bad line.
pub struct NdjsonReader {
  priv mut line_number : Int
  priv mut pending : String
}

///|
/// Create a reader positioned before line 1.
pub fn NdjsonReader::new() -> NdjsonReader {
  { line_number: 0, pending: "", }
}

///|
/// Number of lines read so far.
pub fn NdjsonReader::line_number(self : NdjsonReader) -> Int {
  self.line_number
}

///|
/// Parse the next line of input (without its `\n`). A blank line gives
/// `None`. A bad line raises `NdjsonParseError` with its line number.
pub fn NdjsonReader::read_line(
  self : NdjsonReader,
  line : StringView,
) -> Envelope? raise NdjsonParseError {
  self.line_number += 1
  let trimmed = line.trim()
  if trimmed.length() == 0 {
    return None
  }
  Some(
    parse_ndjson_line(trimmed.to_owned()) catch {
      cause => raise NdjsonParseError(line=self.line_number, cause~)
    },
  )
}

///|
/// Parse every complete line in `chunk`. A partial last line is kept until
/// the next `feed` or `finish`.
pub fn NdjsonReader::feed(
  self : NdjsonReader,
  chunk : String,
) -> Array[Envelope] raise NdjsonParseError {
  let pieces = (self.pending + chunk).split("\n").to_array()
  let envelopes : Array[Envelope] = []
  for i in 0..<(pieces.length() - 1) {
    if self.read_line(pieces[i]) is Some(envelope) {
      envelopes.push(envelope)
    }
  }
  self.pending = pieces[pieces.length() - 1].to_owned()
  envelopes
}

///|
/// Parse the last line when the input does not end with `\n`.
pub fn NdjsonReader::finish(
  self : NdjsonReader,
) -> Envelope? raise NdjsonParseError {
  let rest = self.pending
  self.pending = ""
  if rest.length() == 0 {
    return None
  }
  self.read_line(rest)
}

///|
/// Write this envelope as one NDJSON line, ending with `\n`.
pub fn Envelope::write_ndjson(self : Envelope, logger : &Logger) -> Unit {
  logger.write_string(self.to_ndjson_line())
  logger.write_char('\n')
}

///|
test "NdjsonReader reads envelopes from chunks split mid-line" {
  let input =
    #|{"testRunStarted":{"timestamp":{"seconds":1,"nanos":0}}}
    #|
    #|{"testRunFinished":{"success":true,"timestamp":{"seconds":2,"nanos":0}}}
  let reader = NdjsonReader::new()
  let envelopes : Array[Envelope] = []
  let mut start = 0
  while start < input.length() {
    let end = if start + 7 < input.length() {
      start + 7
    } else {
      input.length()
    }
    envelopes.append(
      reader.feed(input.view(start_offset=start, end_offset=end).to_owned()),
    )
    start = end
  }
  if reader.finish() is Some(envelope) {
    envelopes.push(envelope)
  }
  assert_eq(envelopes.length(), 2)
  assert_true(envelopes[1] is TestRunFinished(_))
}

///|
test "NdjsonReader reports line numbers across chunks" {
  let reader = NdjsonReader::new()
  ignore(
    reader.feed(
      "{\"testRunStarted\":{\"timestamp\":{\"seconds\":1,\"nanos\":0}}}\n\n{ba",
    ),
  )
  let line = try reader.feed("d}\n") catch {
    NdjsonParseError(line~, ..) => line
  } noraise {
    _ => 0
  }
  assert_eq(line, 3)
}

///|
test "NdjsonReader reads one line at a time" {
  let reader = NdjsonReader::new()
  assert_true(reader.read_line("  ") is None)
  assert_true(
    reader.read_line(
      "{\"testRunStarted\":{\"timestamp\":{\"seconds\":1,\"nanos\":0}}}",
    )
    is Some(TestRunStarted(_)),
  )
  assert_eq(reader.line_number(), 2)
}

///|
test "Envelope::write_ndjson writes one line per envelope" {
  let envelopes = parse_ndjson(
    "{\"testRunStarted\":{\"timestamp\":{\"seconds\":1,\"nanos\":0}}}\n{\"testRunFinished\":{\"success\":true,\"timestamp\":{\"seconds\":2,\"nanos\":0}}}\n",
  )
  let buf = StringBuilder()
  for envelope in envelopes {
    envelope.write_ndjson(buf)
  }
  assert_eq(buf.to_string(), envelopes_to_ndjson(envelopes))
}

///|
test "NdjsonReader handles non-BMP characters split across chunks" {
  let line = "{\"source\":{\"uri\":\"😀.feature\",\"data\":\"😀😀\",\"mediaType\":\"text/x.cucumber.gherkin+plain\"}}"
  let reader = NdjsonReader::new()
  let envelopes = reader.feed(
    line + "\n" + line + "\n" + line.view(end_offset=20).to_owned(),
  )
  envelopes.append(reader.feed(line.view(start_offset=20).to_owned() + "\n"))
  assert_eq(envelopes.length(), 3)
  guard! envelopes[2] is Source(s)
  assert_eq(s.data, "😀😀")
}

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

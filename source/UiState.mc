import Toybox.Lang;

module UiState {
  const LOCK_GLYPH_OPEN = 0;
  const LOCK_GLYPH_CLOSED = 1;
  const LOCK_GLYPH_UNKNOWN = 2;

  var loading as Boolean = false;
  var error as String or Null = null;
  var errorCode as Number = 0;
  var statusLine as String = "";
  var lockGlyph as Number = LOCK_GLYPH_CLOSED;
  var rawStatus as Number = 0;

  function resetError() as Void {
    error = null;
    errorCode = 0;
  }

  function setError(msg as String) as Void {
    error = msg;
    errorCode = 0;
    loading = false;
  }

  function setErrorWithCode(msg as String, code as Number) as Void {
    error = msg;
    errorCode = code;
    loading = false;
  }

  function setLoading(v as Boolean) as Void {
    loading = v;
    if (v) {
      error = null;
    }
  }

  function setPartitionStatus(status as Number, line as String, glyph as Number) as Void {
    rawStatus = status;
    statusLine = line;
    lockGlyph = glyph;
    loading = false;
    error = null;
  }
}

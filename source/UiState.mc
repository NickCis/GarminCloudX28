import Toybox.Lang;

module UiState {
  const LOCK_GLYPH_OPEN = 0;
  const LOCK_GLYPH_CLOSED = 1;
  const LOCK_GLYPH_UNKNOWN = 2;

  var loading as Boolean = false;
  var error as String or Null = null;
  var statusLine as String = "";
  var lockGlyph as Number = LOCK_GLYPH_CLOSED;
  var rawStatus as Number = 0;

  function resetError() as Void {
    error = null;
  }

  function setError(msg as String) as Void {
    error = msg;
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

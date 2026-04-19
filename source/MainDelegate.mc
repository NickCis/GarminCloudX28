import Toybox.Communications;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

class MainDelegate extends WatchUi.BehaviorDelegate {
  const OP_NONE = 0;
  const OP_LOGIN = 1;
  const OP_DEVICES = 2;
  const OP_PUT = 3;

  const PUT_REFRESH_DELAY_MS = 4000;

  var _op as Number = 0;
  var _pendingPut as Number = -1;
  var _lastHttpUrl as String = "";
  var _putRefreshTimer as Timer.Timer or Null = null;

  function initialize() {
    BehaviorDelegate.initialize();
    startRefreshAll();
  }

  function onMenu() as Boolean {
    showActionsMenu();
    return true;
  }

  function onSelect() as Boolean {
    showActionsMenu();
    return true;
  }

  function showActionsMenu() as Void {
    if (UiState.loading) {
      return;
    }
    var menu = new X28Menu();
    WatchUi.pushView(menu, new X28MenuDelegate(self), WatchUi.SLIDE_UP);
  }

  function startRefreshAll() as Void {
    cancelPutRefreshDelay();
    _pendingPut = -1;
    if (!Credentials.hasAll()) {
      UiState.setError("Faltan credenciales");
      WatchUi.requestUpdate();
      return;
    }
    UiState.setLoading(true);
    WatchUi.requestUpdate();
    if (SessionStore.isTokenValid()) {
      beginGetDevices();
    } else {
      beginLogin();
    }
  }

  function beginPutWithEnsurePartition(status as Number) as Void {
    if (UiState.loading) {
      return;
    }
    var pid = SessionStore.getPartitionId();
    if (pid == null || pid.length() == 0) {
      _pendingPut = status;
      startRefreshAll();
      return;
    }
    submitPut(status);
  }

  function submitPut(status as Number) as Void {
    cancelPutRefreshDelay();
    var tok = SessionStore.getToken();
    var appId = SessionStore.getAppId();
    var pid = SessionStore.getPartitionId();
    if (tok == null || appId == null || pid == null) {
      startRefreshAll();
      return;
    }
    UiState.setLoading(true);
    WatchUi.requestUpdate();
    _op = OP_PUT;
    var body = {
      "appId" => appId,
      "partitionId" => pid,
      "status" => status,
      "code" => Credentials.pin()
    };
    var opts = {
      :method => Communications.HTTP_REQUEST_METHOD_PUT,
      :headers => {
        "Authorization" => "Bearer " + tok,
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
      },
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };
    var url = "https://api-new.cloudx28.com/v1/n/partitions/status";
    _lastHttpUrl = url;
    HttpDebug.logRequest(url, body, opts);
    Communications.makeWebRequest(url, body, opts, method(:onHttpResponse));
  }

  function beginLogin() as Void {
    _op = OP_LOGIN;
    var mail = Credentials.mail();
    var enc = PasswordUtil.encodeLoginPassword(Credentials.password());
    var body = {
      "mail" => mail,
      "password" => enc,
      "deviceToken" => "deviceToken",
      "uuid" => "uuid"
    };
    HttpDebug.logLoginEncodedPassword(enc);
    var opts = {
      :method => Communications.HTTP_REQUEST_METHOD_POST,
      :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON },
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };
    var url = "https://api-new.cloudx28.com/v1/n/login";
    _lastHttpUrl = url;
    HttpDebug.logRequest(url, body, opts);
    Communications.makeWebRequest(url, body, opts, method(:onHttpResponse));
  }

  function beginGetDevices() as Void {
    var tok = SessionStore.getToken();
    if (tok == null) {
      beginLogin();
      return;
    }
    _op = OP_DEVICES;
    var opts = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => { "Authorization" => "Bearer " + tok },
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };
    var url = "https://api-new.cloudx28.com/v1/n/devices/all/0?orderBy=createdAt";
    _lastHttpUrl = url;
    HttpDebug.logRequest(url, null, opts);
    Communications.makeWebRequest(url, null, opts, method(:onHttpResponse));
  }

  (:typecheck(false))
  function onHttpResponse(responseCode as Number, data as Lang.Dictionary or Lang.String or Null) as Void {
    HttpDebug.logResponse(_lastHttpUrl, responseCode, data);
    if (_op == OP_LOGIN) {
      handleLogin(responseCode, data);
    } else if (_op == OP_DEVICES) {
      handleDevices(responseCode, data);
    } else if (_op == OP_PUT) {
      handlePut(responseCode, data);
    }
  }

  function handleLogin(code as Number, data as Lang.Dictionary or Lang.String or Null) as Void {
    if (code != 200) {
      _op = OP_NONE;
      var detail = "";
      if (code < 0) {
        detail = HttpDebug.communicationsErrorLabel(code);
      } else {
        var norm = normalizeLoginBody(data);
        if (norm != null) {
          detail = loginApiErrorText(norm);
        }
        if (detail.length() == 0 && data instanceof Lang.String) {
          detail = loginSnippetText(data as Lang.String);
        }
      }
      if (detail.length() > 0) {
        UiState.setError("Error login (" + code.toString() + "): " + detail);
      } else {
        UiState.setError("Error login HTTP " + code.toString());
      }
      WatchUi.requestUpdate();
      return;
    }
    var d = normalizeLoginBody(data);
    if (d == null) {
      _op = OP_NONE;
      if (data instanceof Lang.String) {
        UiState.setError("Login: no JSON (" + loginSnippetText(data as Lang.String) + ")");
      } else if (data == null) {
        UiState.setError("Login: respuesta vacía");
      } else {
        UiState.setError("Login: formato JSON inesperado");
      }
      WatchUi.requestUpdate();
      return;
    }
    var token = loginTokenField(d);
    var appId = loginAppIdField(d);
    if (token.length() == 0 || appId.length() == 0) {
      _op = OP_NONE;
      var msg = loginApiErrorText(d);
      if (msg.length() == 0) {
        msg = "Sin token/appId en JSON";
      }
      UiState.setError("Error login: " + msg);
      WatchUi.requestUpdate();
      return;
    }
    var expN = 86400;
    var expRaw = d.get("tokenExpiresIn");
    if (expRaw != null && expRaw instanceof Number) {
      expN = expRaw as Number;
    }
    SessionStore.saveSession(token, appId, expN);
    beginGetDevices();
  }

  function loginTokenField(d as Lang.Dictionary) as String {
    var t = dictString(d, "token");
    if (t.length() == 0) {
      t = dictString(d, "accessToken");
    }
    return t;
  }

  function loginAppIdField(d as Lang.Dictionary) as String {
    var a = dictString(d, "appId");
    if (a.length() == 0) {
      a = dictString(d, "applicationId");
    }
    return a;
  }

  function loginApiErrorText(d as Lang.Dictionary) as String {
    var s = dictString(d, "description");
    if (s.length() == 0) {
      s = dictString(d, "message");
    }
    if (s.length() == 0) {
      s = dictString(d, "error");
    }
    return s;
  }

  function loginSnippetText(s as String) as String {
    var n = s.length();
    if (n <= 72) {
      return s;
    }
    return s.substring(0, 72) + "...";
  }

  (:typecheck(false))
  function normalizeLoginBody(data as Lang.Dictionary or Lang.String or Null) as Lang.Dictionary or Null {
    if (data == null) {
      return null;
    }
    if (data instanceof Lang.String) {
      return null;
    }
    var d = null;
    if (data instanceof Lang.Array) {
      var arr = data as Lang.Array;
      if (arr.size() == 0) {
        return null;
      }
      var first = arr[0];
      if (!(first instanceof Lang.Dictionary)) {
        return null;
      }
      d = first as Lang.Dictionary;
    } else if (data instanceof Lang.Dictionary) {
      d = data as Lang.Dictionary;
    } else {
      return null;
    }
    if (loginTokenField(d).length() > 0 && loginAppIdField(d).length() > 0) {
      return d;
    }
    var inner = unwrapLoginNested(d);
    if (inner != null) {
      return inner;
    }
    return d;
  }

  function unwrapLoginNested(d as Lang.Dictionary) as Lang.Dictionary or Null {
    var inner = d.get("data");
    if (inner != null && inner instanceof Lang.Dictionary) {
      return inner as Lang.Dictionary;
    }
    inner = d.get("payload");
    if (inner != null && inner instanceof Lang.Dictionary) {
      return inner as Lang.Dictionary;
    }
    inner = d.get("result");
    if (inner != null && inner instanceof Lang.Dictionary) {
      return inner as Lang.Dictionary;
    }
    inner = d.get("body");
    if (inner != null && inner instanceof Lang.Dictionary) {
      return inner as Lang.Dictionary;
    }
    return null;
  }

  function handlePut(code as Number, data as Lang.Dictionary or Lang.String or Null) as Void {
    if (code < 200 || code >= 300) {
      if (code == 401 || code == 403) {
        SessionStore.clearSession();
        beginLogin();
        return;
      }
      _op = OP_NONE;
      UiState.setError("Error al actualizar: HTTP " + code.toString());
      WatchUi.requestUpdate();
      return;
    }
    scheduleRefreshAfterPutDelay();
  }

  function cancelPutRefreshDelay() as Void {
    if (_putRefreshTimer != null) {
      (_putRefreshTimer as Timer.Timer).stop();
      _putRefreshTimer = null;
    }
  }

  function scheduleRefreshAfterPutDelay() as Void {
    _op = OP_NONE;
    UiState.setLoading(true);
    WatchUi.requestUpdate();
    cancelPutRefreshDelay();
    var t = new Timer.Timer();
    _putRefreshTimer = t;
    t.start(method(:onPutRefreshDelay), PUT_REFRESH_DELAY_MS, false);
  }

  function onPutRefreshDelay() as Void {
    cancelPutRefreshDelay();
    beginGetDevices();
  }

  (:typecheck(false))
  function handleDevices(code as Number, data as Lang.Dictionary or Lang.String or Null) as Void {
    if (code == 401 || code == 403) {
      SessionStore.clearSession();
      beginLogin();
      return;
    }
    if (code != 200) {
      _op = OP_NONE;
      UiState.setError("Error datos: HTTP " + code.toString());
      WatchUi.requestUpdate();
      return;
    }
    if (data == null) {
      _op = OP_NONE;
      UiState.setError("Respuesta inválida");
      WatchUi.requestUpdate();
      return;
    }
    if (!(data instanceof Lang.Array)) {
      _op = OP_NONE;
      UiState.setError("Respuesta inválida");
      WatchUi.requestUpdate();
      return;
    }
    var arr = data as Lang.Array;
    if (arr.size() == 0) {
      _op = OP_NONE;
      UiState.setError("Sin dispositivos");
      WatchUi.requestUpdate();
      return;
    }
    var dev0 = arr[0];
    if (!(dev0 instanceof Lang.Dictionary)) {
      _op = OP_NONE;
      UiState.setError("Formato dispositivo");
      WatchUi.requestUpdate();
      return;
    }
    var dev = dev0 as Lang.Dictionary;
    var pinfoList = dev.get("partitionsInfo");
    if (pinfoList == null || !(pinfoList instanceof Lang.Array)) {
      _op = OP_NONE;
      UiState.setError("Sin partitionsInfo");
      WatchUi.requestUpdate();
      return;
    }
    var piArr = pinfoList as Lang.Array;
    if (piArr.size() == 0) {
      _op = OP_NONE;
      UiState.setError("Sin particiones");
      WatchUi.requestUpdate();
      return;
    }
    var p0 = piArr[0];
    if (!(p0 instanceof Lang.Dictionary)) {
      _op = OP_NONE;
      UiState.setError("Formato partición");
      WatchUi.requestUpdate();
      return;
    }
    var pinfo = p0 as Lang.Dictionary;
    var part = pinfo.get("partition");
    if (part == null || !(part instanceof Lang.Dictionary)) {
      _op = OP_NONE;
      UiState.setError("Sin partition");
      WatchUi.requestUpdate();
      return;
    }
    var pd = part as Lang.Dictionary;
    var pid = dictString(pd, "id");
    if (pid.length() == 0) {
      _op = OP_NONE;
      UiState.setError("Sin partition.id");
      WatchUi.requestUpdate();
      return;
    }
    SessionStore.setPartitionId(pid);
    var st = dictNumber(pd, "status");
    var line = lineForStatus(st);
    var glyph = UiState.LOCK_GLYPH_UNKNOWN;
    if (st == 1) {
      glyph = UiState.LOCK_GLYPH_OPEN;
    } else if (st == 3 || st == 4) {
      glyph = UiState.LOCK_GLYPH_CLOSED;
    }
    UiState.setPartitionStatus(st, line, glyph);
    WatchUi.requestUpdate();

    if (_pendingPut >= 1) {
      var ps = _pendingPut;
      _pendingPut = -1;
      submitPut(ps);
      return;
    }
    _op = OP_NONE;
  }

  function lineForStatus(st as Number) as String {
    if (st == 1) {
      return "Desactivada";
    }
    if (st == 3) {
      return "Activada: Estoy";
    }
    if (st == 4) {
      return "Activada: Me voy";
    }
    return "Desconocido: " + st.toString();
  }

  function dictString(d as Lang.Dictionary, key as String) as String {
    var v = d.get(key);
    if (v == null) {
      return "";
    }
    if (v instanceof String) {
      return v as String;
    }
    return v.toString();
  }

  function dictNumber(d as Lang.Dictionary, key as String) as Number {
    var v = d.get(key);
    if (v == null) {
      return 0;
    }
    if (v instanceof Number) {
      return v as Number;
    }
    return 0;
  }
}

class X28Menu extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({ :title => "Opciones" });
    addItem(new WatchUi.MenuItem("Actualizar", null, 0, null));
    var st = UiState.rawStatus;
    if (st != 1) {
      addItem(new WatchUi.MenuItem("Desactivar", null, 1, null));
    }
    if (st != 3 && st != 4) {
      addItem(new WatchUi.MenuItem("Activar: Estoy", null, 3, null));
      addItem(new WatchUi.MenuItem("Activar: Me voy", null, 4, null));
    }
  }
}

class X28MenuDelegate extends WatchUi.Menu2InputDelegate {
  var _owner as MainDelegate;

  function initialize(owner as MainDelegate) {
    Menu2InputDelegate.initialize();
    _owner = owner;
  }

  function onSelect(item as WatchUi.MenuItem) as Void {
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    var id = item.getId();
    if (id == null || !(id instanceof Number)) {
      return;
    }
    var n = id as Number;
    if (n == 0) {
      _owner.startRefreshAll();
    } else if (n == 1) {
      _owner.beginPutWithEnsurePartition(1);
    } else if (n == 3) {
      _owner.beginPutWithEnsurePartition(3);
    } else if (n == 4) {
      _owner.beginPutWithEnsurePartition(4);
    }
  }
}

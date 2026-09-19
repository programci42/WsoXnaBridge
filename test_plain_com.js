try {
    var obj = new ActiveXObject("WsoXnaBridge.Renderer");
    WScript.Echo("OK: object created, typeof=" + typeof(obj));
} catch (e) {
    WScript.Echo("FAILED: " + e.message + " (number=" + e.number + ")");
}

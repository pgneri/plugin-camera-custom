var customCamera = {
    getPicture: function(success, failure, options) {
        options = options || {};
        var filename = "customMask";
        var quality = options.quality || 100;
        var targetWidth = options.targetWidth || -1;
        var targetHeight = options.targetHeight || -1;
        var title = options.title || "";
        var buttonDone = options.buttonDone || "OK";
        var buttonRestart = options.buttonRestart || "Take another picture";
        var buttonCancel = options.buttonCancel || "Cancel";
        var toggleCamera = options.toggleCamera === true ? "YES" : "";

        cordova.exec(success, failure, "CustomCamera", "takePicture", [filename, quality, targetWidth, targetHeight, title, buttonDone, buttonRestart, buttonCancel, toggleCamera]);
    }
};

module.exports = customCamera;

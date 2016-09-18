### Description

Cordova plugin which mask camera.

### Using the plugin

```js
navigator.customCamera.getPicture(success, failure, [ options ]);
```

### Options

|         Option       | Default Value |        Description        |
|----------------------|---------------|---------------------------|
| quality | 100 | The compression level to use when saving the image - a value between 1 and 100, 100 meaning no reduction in quality. |
| targetWidth | -1 | The target width of the scaled image, -1 to disable scaling. |
| targetHeight | -1 | The target height of the scaled image, -1 to disable scaling.  |
|title | null | Title to camera preview, null to disabled.  |
|buttonDone | 'OK' | ButtonDone to Image preview, default 'OK'. |
|buttonRestart | 'Take another picture' | ButtonRestart to Image preview, default 'Take another picture'. |
|buttonCancel | 'Cancel' | ButtonCancel to cancel get Picture, default 'Cancel'. |
|toggleCamera | false | toggleCamera to show button the alter front and back camera, default false. |

### Image scaling

Setting both targetWidth and targetHeight to -1 will disable image scaling. Setting both values to positive integers will scale the image to that exact size which may result in distortion. If the aspect ratio should be respected, supply only the targetWidth or targetHeight and the other will be set based on the aspect ratio.

### Example

```js
navigator.customCamera.getPicture(function success(base64) {
    document.getElementById('photo').src = "data:image/jpeg;base64,"+base64;
}, function failure(error) {
    alert(error);
}, {
    quality: 100,
    targetWidth: 100,
    targetHeight:100,
    title:'Title to camera',
    buttonDone:'OK',
    buttonRestart:'Take another picture',
    buttonCancel:'Cancel',
    toggleCamera: true
});
```

https://github.com/pgneri/cordova.app.exempleCustomCamera

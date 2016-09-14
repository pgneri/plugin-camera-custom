### Description

Cordova plugin which mask Selfie camera.

### Using the plugin

```js
navigator.customCamera.getPicture(filename, success, failure, [ options ]);
```

### Options

|         Option       | Default Value |        Description        |
|----------------------|---------------|---------------------------|
| quality | 100 | The compression level to use when saving the image - a value between 1 and 100, 100 meaning no reduction in quality. |
| targetWidth | -1 | The target width of the scaled image, -1 to disable scaling. |
| targetHeight | -1 | The target height of the scaled image, -1 to disable scaling.  |

### Image scaling

Setting both targetWidth and targetHeight to -1 will disable image scaling. Setting both values to positive integers will scale the image to that exact size which may result in distortion. If the aspect ratio should be respected, supply only the targetWidth or targetHeight and the other will be set based on the aspect ratio.

### Example

```js
navigator.customCamera.getPicture(filename, function success(base64) {
    console.log(base64)
}, function failure(error) {
    alert(error);
}, {
    quality: 80,
    targetWidth: 120,
    targetHeight: 120
});
```

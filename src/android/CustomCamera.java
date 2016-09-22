package com.pgneri.plugin.custom.camera;

import android.Manifest;
import android.content.Intent;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

/**
 * This is the cordova plugin interface
 */
public class CustomCamera extends CordovaPlugin {

    private CallbackContext callbackContext;
    private JSONArray args;

    @Override
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;
        this.args = args;
        if (action.equals(TakePictureAction.ACTION)) {
            if (cordova.hasPermission(Manifest.permission.CAMERA)) {
                this.takePicture(args, callbackContext);
            } else {
                this.requestPermission();
            }
            return true;
        }
        return false;
    }

    private void takePicture(final JSONArray args, CallbackContext callbackContext) {
        final TakePictureAction takePictureAction = new TakePictureAction(this, cordova, callbackContext);
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                takePictureAction.execute(args);
            }
        });
    }

    private void requestPermission() {
        cordova.requestPermission(this, 0, Manifest.permission.CAMERA);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        this.callbackContext.success("Sucesso");
    }

    @Override
    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        this.takePicture(args, callbackContext);
    }
}

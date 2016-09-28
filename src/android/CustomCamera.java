package com.pgneri.plugin.custom.camera;

import android.Manifest;
import android.content.Intent;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.Serializable;

/**
 * This is the cordova plugin interface
 */
public class CustomCamera extends CordovaPlugin {

    public static final String INTENT_PARAMS = "params";
    private CallbackContext callbackContext;
    private JSONArray args;

    @Override
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;
        this.args = args;
        if (action.equals("takePicture")) {
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
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                Params params = extractParams(args);
                if (params == null) return;
                final Intent intent = new Intent(cordova.getActivity(), CameraActivity.class);
                intent.putExtra(INTENT_PARAMS, params);
                cordova.startActivityForResult(CustomCamera.this, intent, 0);
            }
        });
    }


    private void requestPermission() {
        cordova.requestPermission(this, 0, Manifest.permission.CAMERA);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        if (intent == null) {
            callbackContext.error("No image selected");
        } else {
            String base64 = intent.getStringExtra(CameraActivity.OUTPUT);
            if (base64 != null) {
                this.callbackContext.success(base64);
            } else {
                callbackContext.error("No image selected");
            }
        }
    }

    @Override
    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        this.takePicture(args, callbackContext);
    }

    private Params extractParams(JSONArray args) {
        Params params;
        try {
            params = new Params(args);
        } catch (JSONException e) {
            Log.d("error", e.getMessage());
            this.callbackContext.error("Invalid Parameters");
            return null;
        }
        return params;
    }


    public static final class Params implements Serializable {
        private final String filename;
        private final int quality;
        private final int targetWidth;
        private final int targetHeight;
        private final String title;
        private final String buttonDone;
        private final String buttonRestart;
        private final String buttonCancel;
        private final boolean toggleCamera;

        public Params(JSONArray args) throws JSONException {
            int i = 0;
            this.filename = args.getString(i++);
            this.quality = args.getInt(i++);
            this.targetWidth = args.getInt(i++);
            this.targetHeight = args.getInt(i++);
            this.title = args.getString(i++);
            this.buttonDone = args.getString(i++);
            this.buttonRestart = args.getString(i++);
            this.buttonCancel = args.getString(i++);
            this.toggleCamera = "YES".equals(args.getString(i));
        }

        public String getFilename() {
            return filename;
        }

        public int getQuality() {
            return quality;
        }

        public int getTargetWidth() {
            return targetWidth;
        }

        public int getTargetHeight() {
            return targetHeight;
        }

        public String getTitle() {
            return title;
        }

        public String getButtonDone() {
            return buttonDone;
        }

        public String getButtonRestart() {
            return buttonRestart;
        }

        public String getButtonCancel() {
            return buttonCancel;
        }

        public boolean isToggleCamera() {
            return toggleCamera;
        }

        @Override
        public String toString() {
            return "Params{" +
                    "filename='" + filename + '\'' +
                    ", quality=" + quality +
                    ", targetWidth=" + targetWidth +
                    ", targetHeight=" + targetHeight +
                    ", title='" + title + '\'' +
                    ", buttonDone='" + buttonDone + '\'' +
                    ", buttonRestart='" + buttonRestart + '\'' +
                    ", buttonCancel='" + buttonCancel + '\'' +
                    ", toggleCamera=" + toggleCamera +
                    '}';
        }
    }
}

package com.pgneri.plugin.custom.camera;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

/**
 * Take Picture Action
 */
public class TakePictureAction {

    public static final String ACTION = "takePicture";

    private final CallbackContext callbackContext;
    private final CordovaInterface cordova;
    private final CordovaPlugin cordovaPlugin;

    public TakePictureAction(CordovaPlugin cordovaPlugin, CordovaInterface cordova, CallbackContext callbackContext) {
        this.cordovaPlugin = cordovaPlugin;
        this.cordova = cordova;
        this.callbackContext = callbackContext;
    }

    public void execute(JSONArray args) {
        Params params = this.extractParams(args);
        if (params == null) return;

        Context context = cordova.getActivity().getApplicationContext();
        Intent intent = new Intent(context, CameraActivity.class);
        cordova.startActivityForResult(cordovaPlugin, intent, 0);
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

    private static final class Params {
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

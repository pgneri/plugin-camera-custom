package com.pgneri.plugin.custom.camera;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Point;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.RectF;
import android.graphics.drawable.GradientDrawable;
import android.hardware.Camera;
import android.os.Build;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;
import android.view.Gravity;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import android.widget.TextView;

import org.apache.cordova.CordovaActivity;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * Camera Activity
 */
@SuppressWarnings("deprecation")
public class CameraActivity extends Activity implements SurfaceHolder.Callback {

    public static final String OUTPUT = "results";
    private static final String ERROR = "error";
    private Camera mCamera;
    private boolean mPreviewRunning = false;
    private SurfaceView mSurfaceView;
    private RelativeLayout mContainer;
    private ImageButton takePictureButton;
    private RelativeLayout actionsContainer;
    private AnotherPictureButton anotherPictureButton;
    private OKButton okButton;
    private Bitmap image;
    private CameraOverlay cameraOverlay;
    private int overlayHeight;
    private int screenHeight;
    private PicturePreview mPicturePreview;
    private CustomCamera.Params params;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        params = (CustomCamera.Params) getIntent().getExtras().get(CustomCamera.INTENT_PARAMS);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().getDecorView().setBackgroundColor(Color.BLACK);

        mContainer = new RelativeLayout(this);
        mContainer.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
        setContentView(mContainer);

        mSurfaceView = new SurfaceView(this);
        mSurfaceView.getHolder().addCallback(this);
        mSurfaceView.getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
        //   mContainer.addView(mSurfaceView);

        actionsContainer = new RelativeLayout(this);
        LayoutParams actionContainerLayoutParams = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        actionContainerLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        actionContainerLayoutParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
        actionsContainer.setLayoutParams(actionContainerLayoutParams);
        mContainer.addView(actionsContainer);

        takePictureButton = new TakePictureButton(this);
        okButton = new OKButton(this, params.getButtonDone());
        anotherPictureButton = new AnotherPictureButton(this, params.getButtonRestart());

        this.showTakePictureState();
    }


    private void showTakePictureState() {
        actionsContainer.removeAllViews();
        if (mPicturePreview != null)
            this.mContainer.removeView(mPicturePreview);
        this.mContainer.addView(mSurfaceView);
        if (mCamera != null)
            startPreview();
        actionsContainer.addView(takePictureButton);
    }

    private void showSelectPictureState() {
        this.mContainer.setPadding(0, ((screenHeight - overlayHeight) / 5), 0, 0);
        actionsContainer.removeAllViews();
        mPicturePreview = new PicturePreview(this, this.image, overlayHeight);
        this.mContainer.removeView(mSurfaceView);
        this.mContainer.addView(mPicturePreview);
        actionsContainer.addView(okButton);
        this.mContainer.removeView(cameraOverlay);
        this.mContainer.addView(cameraOverlay);
        actionsContainer.addView(anotherPictureButton);
        mContainer.removeView(mSurfaceView);
    }


    @Override
    public void surfaceCreated(SurfaceHolder surfaceHolder) {
        if (mCamera != null) {
            mCamera.stopPreview();
            mCamera.release();
        }
        mCamera = Camera.open(Camera.CameraInfo.CAMERA_FACING_FRONT);
        final Camera.CameraInfo info = new Camera.CameraInfo();
        Camera.getCameraInfo(Camera.CameraInfo.CAMERA_FACING_FRONT, info);
        Camera.Parameters parameters = mCamera.getParameters();
        parameters.set("orientation", "portrait");
        parameters.setRotation(270);
        mCamera.setParameters(parameters);

        final Camera.Size pictureSize = mCamera.getParameters().getPictureSize();

        final Point screenSize = new Point();
        getWindowManager().getDefaultDisplay().getSize(screenSize);

        float pictureSizeRatio = ((float) pictureSize.height) / ((float) pictureSize.width);
        final Point scaledSize = new Point(screenSize.x, (int) (screenSize.y * pictureSizeRatio));

        this.mSurfaceView.getHolder().setFixedSize(scaledSize.x, scaledSize.y);
        screenHeight = screenSize.y;
        overlayHeight = scaledSize.y;
        cameraOverlay = new CameraOverlay(this, overlayHeight);
        this.mContainer.addView(cameraOverlay);

        this.mContainer.setPadding(0, (screenHeight - overlayHeight) / 5, 0, 0);
        TextView instructions = new TextView(this);
        LayoutParams layoutParams = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
        instructions.setLayoutParams(layoutParams);
        instructions.setGravity(Gravity.CENTER_HORIZONTAL);
        instructions.setHeight((screenHeight - overlayHeight) / 5);
        instructions.setText(params.getTitle());
        instructions.setBackgroundColor(Color.TRANSPARENT);
        this.mContainer.addView(instructions);
    }

    @Override
    public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {
        this.startPreview();
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
        this.stopPreview();
    }

    @Override
    protected void onDestroy() {
        if(this.mCamera != null) {
            this.mCamera.stopPreview();
            this.mCamera.release();
        }
        super.onDestroy();
    }

    private void startPreview() {
        if (this.mPreviewRunning) {
            this.mCamera.stopPreview();
        }
        try {
            this.mCamera.setPreviewDisplay(mSurfaceView.getHolder());
            this.mCamera.setDisplayOrientation(90);
            this.mCamera.startPreview();
            this.mPreviewRunning = true;
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void stopPreview() {
        if(this.mCamera != null) {
            this.mCamera.stopPreview();
        }
        this.mPreviewRunning = false;
    }


    private Bitmap cropImage(Bitmap source) {
        int originalWidth = source.getWidth();
        int originalHeigth = source.getHeight();
        int overlayDiameter = Math.min(originalWidth, originalHeigth);
        int x = (originalWidth - overlayDiameter) / 2;
        int y = (originalHeigth - overlayDiameter) / 2;
        return Bitmap.createBitmap(source, x, y, overlayDiameter, overlayDiameter);
    }

    private Bitmap resizeImage(Bitmap image, int targetWidth, int targetHeight) {
        if(targetWidth != -1 && targetHeight != -1) {
            return Bitmap.createScaledBitmap(image, targetWidth, targetHeight, false);
        } else {
            return image;
        }
    }

    private void finish(String base64) {
        Bundle conData = new Bundle();
        conData.putString(OUTPUT, base64);
        Intent intent = new Intent();
        intent.putExtras(conData);
        setResult(0, intent);
        CameraActivity.this.finish();
    }



    private String toBase64(Bitmap image) {
        final ByteArrayOutputStream stream = new ByteArrayOutputStream();
        image.compress(Bitmap.CompressFormat.JPEG, params.getQuality(), stream);
        return Base64.encodeToString(stream.toByteArray(), Base64.DEFAULT);
    }

    private static class PicturePreview extends View {
        private final int height;
        private Bitmap bitmap;

        private Bitmap image;

        public PicturePreview(Context context, Bitmap image, int height) {
            super(context);
            this.height = height;
            this.image = image;
        }

        private Bitmap createBitmap(int height) {
            return Bitmap.createScaledBitmap(this.image, getWidth(), height, false);
        }

        @Override
        protected void onDraw(Canvas canvas) {
            if (bitmap == null) {
                bitmap = createBitmap(height);
            }
            super.onDraw(canvas);
            canvas.drawBitmap(this.bitmap, 0, 0, null);
        }

    }

    private static class CameraOverlay extends View {
        private final int height;

        private Bitmap bitmap;

        public CameraOverlay(Context context, int height) {
            super(context);
            this.height = height;
        }

        private Bitmap createBitmap(int height) {
            final Bitmap windowFrame = Bitmap.createBitmap(getWidth(), getHeight(), Bitmap.Config.ARGB_8888);
            final Canvas osCanvas = new Canvas(windowFrame);
            final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);

            final RectF outerRect = new RectF(0, 0, getWidth(), height);
            paint.setColor(Color.BLACK);
            paint.setAlpha(100);
            osCanvas.drawRect(outerRect, paint);

            paint.setColor(Color.TRANSPARENT);
            paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_OUT));
            final float centerX = getWidth() / 2;
            final float centerY = height / 2;
            float radius = Math.min(getWidth(), height) / 2;
            osCanvas.drawCircle(centerX, centerY, radius, paint);

            return windowFrame;
        }

        @Override
        protected void onDraw(Canvas canvas) {
            super.onDraw(canvas);
            if (bitmap == null) {
                bitmap = createBitmap(height);
            }
            canvas.drawBitmap(this.bitmap, 0, 0, null);
        }

    }

    private class OKButton extends Button implements View.OnClickListener {

        public OKButton(Context context, String text) {
            super(context);
            LayoutParams buttonLayout = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
            buttonLayout.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
            buttonLayout.setMargins(0, 0, 50, 50);
            this.setLayoutParams(buttonLayout);
            this.setText(text);
            this.setTextColor(Color.BLACK);
            this.setPadding(5, 0, 5, 0);
            GradientDrawable shape = new GradientDrawable();
            shape.setColor(Color.WHITE);
            shape.setCornerRadius(8);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                this.setBackground(shape);
            } else {
                this.setBackgroundDrawable(shape);
            }
            this.setOnClickListener(this);
        }

        @Override
        public void onClick(View view) {
            Bitmap image = CameraActivity.this.cropImage(CameraActivity.this.image);
            image = CameraActivity.this.resizeImage(image, params.getTargetWidth(), params.getTargetHeight());
            CameraActivity.this.finish(CameraActivity.this.toBase64(image));
        }

    }


    private class AnotherPictureButton extends Button implements View.OnClickListener {

        public AnotherPictureButton(Context context, String text) {
            super(context);
            LayoutParams buttonLayout2 = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
            buttonLayout2.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
            buttonLayout2.setMargins(50, 0, 50, 0);
            this.setLayoutParams(buttonLayout2);
            this.setText(text);
            this.setPadding(20, 0, 20, 0);
            this.setTextColor(Color.BLACK);
            GradientDrawable shape = new GradientDrawable();
            shape.setColor(Color.WHITE);
            shape.setCornerRadius(8);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                this.setBackground(shape);
            } else {
                this.setBackgroundDrawable(shape);
            }
            this.setOnClickListener(this);
        }

        @Override
        public void onClick(View view) {
            CameraActivity.this.showTakePictureState();
        }
    }

    private class TakePictureButton extends ImageButton implements View.OnClickListener, Camera.PictureCallback {

        public TakePictureButton(Context context) {
            super(context);
            LayoutParams takePictureButtonLayoutParams = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
            takePictureButtonLayoutParams.addRule(RelativeLayout.CENTER_IN_PARENT);
            takePictureButtonLayoutParams.addRule(RelativeLayout.CENTER_VERTICAL);
            this.setLayoutParams(takePictureButtonLayoutParams);
            this.setBackgroundColor(Color.BLACK);
            try {
                InputStream file = context.getAssets().open("www/img/icons/input-foto.png");
                this.setImageBitmap(BitmapFactory.decodeStream(file));
            } catch (IOException e) {
                e.printStackTrace();
            }
            this.setOnClickListener(this);
        }

        @Override
        public void onClick(View view) {
            mCamera.takePicture(null, null, this);
        }

        @Override
        public void onPictureTaken(byte[] bytes, Camera camera) {
            CameraActivity.this.stopPreview();
            final Bitmap flippedBitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
            final Matrix m = new Matrix();
            m.preScale(-1, 1);
            CameraActivity.this.image = Bitmap.createBitmap(flippedBitmap, 0, 0, flippedBitmap.getWidth(), flippedBitmap.getHeight(), m, false);
            CameraActivity.this.showSelectPictureState();
        }
    }
}

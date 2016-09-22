package com.pgneri.plugin.custom.camera;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Point;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.RectF;
import android.hardware.Camera;
import android.os.Bundle;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;

import java.io.IOException;

/**
 * Camera Activity
 */
public class CameraActivity extends Activity implements SurfaceHolder.Callback {

    private Camera mCamera;
    private boolean mPreviewRunning = false;
    private SurfaceView mSurfaceView;
    private RelativeLayout mContainer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
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
        mContainer.addView(mSurfaceView);


    }


    @Override
    public void surfaceCreated(SurfaceHolder surfaceHolder) {
        mCamera = Camera.open(Camera.CameraInfo.CAMERA_FACING_FRONT);

        Camera.Size pictureSize = mCamera.getParameters().getPictureSize();

        Point screenSize = new Point();
        getWindowManager().getDefaultDisplay().getSize(screenSize);

        float pictureSizeRatio = ((float) pictureSize.height) / ((float) pictureSize.width);
        Point scaledSize = new Point(screenSize.x, (int) (screenSize.y * pictureSizeRatio));

        mSurfaceView.getHolder().setFixedSize(scaledSize.x, scaledSize.y);
        mContainer.setPadding(0, (screenSize.y - scaledSize.y) / 2, 0, 0);

        final CameraOverlay cameraOverlay = new CameraOverlay(this, scaledSize.y);
        this.mContainer.addView(cameraOverlay);
    }

    @Override
    public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {
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

    @Override
    public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
        this.mCamera.stopPreview();
        this.mPreviewRunning = false;
    }


    /**
     * Camera Overlay
     */
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
            if (bitmap == null) {
                this.bitmap = this.createBitmap(this.height);
            }
            super.onDraw(canvas);
            canvas.drawBitmap(this.bitmap, 0, 0, null);
        }
    }
}

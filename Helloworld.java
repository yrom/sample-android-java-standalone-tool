package com.example;
import android.os.Build;
import android.util.Log;
public class Helloworld {

    static { System.loadLibrary("hello"); }
    public static native String stringFromJNI();

    public static void main(String[] args) {
        Log.i("@@", "Hello world, " + Build.MANUFACTURER + " "+ Build.MODEL + "!");
        Log.i("@@", stringFromJNI());
        System.out.println(stringFromJNI());
        System.out.println("DONE.");
    }
    

    public static String getBuildVersion() {
        return Build.VERSION.RELEASE;
    }
}
#if defined(__ANDROID__)
#include <android/log.h>
#else
#include <stdio.h>
#endif
#include <assert.h>
#include <inttypes.h>
#include <jni.h>
#include <pthread.h>
#include <stdlib.h>
#include <string.h>
#if defined(__clang__) || defined(__GNUC__)
#define ATTRIBUTE_NO_SANITIZE_ADDRESS __attribute__((no_sanitize_address))
#else
#define ATTRIBUTE_NO_SANITIZE_ADDRESS
#endif
// Android log function wrappers
static const char *kTAG = "hello-jni";
#if defined(__ANDROID__)
#define LOGI(...) \
  ((void)__android_log_print(ANDROID_LOG_INFO, kTAG, __VA_ARGS__))
#define LOGW(...) \
  ((void)__android_log_print(ANDROID_LOG_WARN, kTAG, __VA_ARGS__))
#define LOGE(...) \
  ((void)__android_log_print(ANDROID_LOG_ERROR, kTAG, __VA_ARGS__))
#else
#define LOGI(...) \
  ((void)printf(__VA_ARGS__))
#define LOGW(...) \
  ((void)printf(__VA_ARGS__))
#define LOGE(...) \
  ((void)printf(__VA_ARGS__))
#endif
typedef struct JniContext
{
  JavaVM *javaVM;
  jclass main;
} JniContext;
JniContext g_ctx;

JNIEXPORT jstring JNICALL
Java_com_example_Helloworld_stringFromJNI(JNIEnv *env,
                                          jobject thiz)
{
#if defined(__arm__)
#if defined(__ARM_ARCH_7A__)
#if defined(__ARM_NEON__)
#if defined(__ARM_PCS_VFP)
#define ABI "armeabi-v7a/NEON (hard-float)"
#else
#define ABI "armeabi-v7a/NEON"
#endif
#else
#if defined(__ARM_PCS_VFP)
#define ABI "armeabi-v7a (hard-float)"
#else
#define ABI "armeabi-v7a"
#endif
#endif
#else
#define ABI "armeabi"
#endif
#elif defined(__i386__)
#define ABI "x86"
#elif defined(__x86_64__)
#define ABI "x86_64"
#elif defined(__aarch64__)
#define ABI "arm64-v8a"
#else
#define ABI "unknown"
#endif
  jclass clz = g_ctx.main;
  jmethodID versionFunc = (*env)->GetStaticMethodID(env, clz, "getBuildVersion", "()Ljava/lang/String;");

  jstring buildVersion = (*env)->CallStaticObjectMethod(env, clz, versionFunc);
  const char *version = (*env)->GetStringUTFChars(env, buildVersion, NULL);

  if (!version)
  {
    LOGE("Unable to get version string");
  }
  else
  {
    LOGI("Build Version - %s\n", version);
    (*env)->ReleaseStringUTFChars(env, buildVersion, version);
  }
  (*env)->DeleteLocalRef(env, buildVersion);

  return (*env)->NewStringUTF(env,
                              "Hello from JNI !  Compiled with ABI " ABI ".");
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved)
{
  JNIEnv *env;
  memset(&g_ctx, 0, sizeof(g_ctx));
  if ((*vm)->GetEnv(vm, (void **)&env, JNI_VERSION_1_6) != JNI_OK)
  {
    return JNI_ERR;
  }
  g_ctx.javaVM = vm;

  jclass clz =
      (*env)->FindClass(env, "com/example/Helloworld");
  if (clz == NULL)
  {
    LOGE("Unable to get class com.example.Helloworld");
    return JNI_ERR;
  }
  g_ctx.main = (*env)->NewGlobalRef(env, clz);
  return JNI_VERSION_1_6;
}

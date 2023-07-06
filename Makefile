BUILD_DIR=build

JAVAC_OPTS=-source 1.8 -target 1.8 -cp .:$(ANDROID_HOME)/platforms/android-30/android.jar

APP_PROCESS=app_process
JARFILE=helloworld.jar
ifeq ($(ARCH),arm)
TARGET=--target=armv7-none-linux-androideabi19 -march=armv7-a -mfpu=vfpv3-d16
APP_PROCESS=app_process32
else
TARGET=--target=aarch64-none-linux-android21
endif

$(BUILD_DIR)/$(JARFILE) : Helloworld.java
	test -d $(BUILD_DIR) || mkdir $(BUILD_DIR)	
	$(JAVA_HOME)/bin/javac $(JAVAC_OPTS) -d $(BUILD_DIR)/classes Helloworld.java
	$(ANDROID_HOME)/build-tools/30.0.2/dx --output=$(BUILD_DIR)/$(JARFILE) --dex ./$(BUILD_DIR)/classes

$(BUILD_DIR)/libhello.so : hello-jni.c
	test -d $(BUILD_DIR) || mkdir $(BUILD_DIR)
	$(ANDROID_NDK_STANDALONE)/bin/clang \
		$(TARGET) --gcc-toolchain=$(ANDROID_NDK_STANDALONE) \
		--sysroot $(ANDROID_NDK_STANDALONE)/sysroot \
		-L$(ANDROID_NDK_STANDALONE)/sysroot/usr/lib \
		-shared -g -DANDROID -fdata-sections -ffunction-sections -funwind-tables \
		-fstack-protector-strong -no-canonical-prefixes -fno-addrsig -fPIC \
		$(CFLAGS) -Wl,--exclude-libs,libgcc.a -Wl,--exclude-libs,libatomic.a \
		-Wl,--build-id -Wl,--warn-shared-textrel \
		-Wl,--no-undefined -Wl,--as-needed \
		$(LINKFLAGS) -Wl,-llog \
		-Wl,-soname,libhello.so \
		-o $(BUILD_DIR)/libhello.so hello-jni.c 
$(BUILD_DIR)/helloworld : run.sh.m4
	m4 -D JARFILE=$(JARFILE) -D APP_PROCESS=$(APP_PROCESS) -D MAIN_CLASS=com.example.Helloworld run.sh.m4 > $(BUILD_DIR)/helloworld
all: $(BUILD_DIR)/$(JARFILE) $(BUILD_DIR)/libhello.so $(BUILD_DIR)/helloworld
.PHONY : clean deploy
deploy : all
	adb shell mkdir /data/local/tmp/helloworld
	adb push --sync $(BUILD_DIR)/$(JARFILE)  $(BUILD_DIR)/libhello.so  $(BUILD_DIR)/helloworld /data/local/tmp/helloworld/
	adb shell chmod a+x /data/local/tmp/helloworld/helloworld
	$(info 	adb shell /data/local/tmp/helloworld/helloworld) 
clean :
	test -d $(BUILD_DIR) && rm -rf $(BUILD_DIR) || true
	adb shell -n "test -d /data/local/tmp/helloworld && rm -rf /data/local/tmp/helloworld || true"
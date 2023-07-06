#!/system/bin/sh
HERE="$(cd "$(dirname "$0")" && pwd)"

export CLASSPATH=$HERE/JARFILE
export ANDROID_DATA=$HERE
export LD_LIBRARY_PATH="$HERE"

if [ -f "$HERE/libc++_shared.so" ]; then
    # Workaround for https://github.com/android-ndk/ndk/issues/988.
    export LD_PRELOAD="$HERE/libc++_shared.so"
fi

echo "try MAIN_CLASS with LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
cmd="APP_PROCESS $HERE MAIN_CLASS $@"
echo "run: $cmd"
exec $cmd
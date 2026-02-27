#!/bin/bash
FLUTTER_ROOT=$(cat "/Users/tuanios_su12/learn_flutter/learnflutter/.flutter_sdk_path")
export FLUTTER_ROOT
export PATH="$FLUTTER_ROOT/bin:$PATH"
flutter "$@"

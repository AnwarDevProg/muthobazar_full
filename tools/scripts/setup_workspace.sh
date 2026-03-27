#!/usr/bin/env bash
set -e
dart pub global activate melos && melos bootstrap && melos run pub_get
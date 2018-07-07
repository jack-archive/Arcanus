#!/bin/bash

rm -rf Package.resolved ./.build/ Arcanus.xcodeproj/
swift package update
swift package generate-xcodeproj
open ./Arcanus.xcodeproj
swift build

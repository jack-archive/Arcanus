#!/bin/bash

#rm -rf Package.resolved ./.build/ Arcanus.xcodeproj/
# swift package update
rm -r Arcanus.xcodeproj/ Build/ DerivedData/ Index/
swift package generate-xcodeproj
open ./Arcanus.xcodeproj

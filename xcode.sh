#!/bin/bash

swift package update
swift package generate-xcodeproj
open ./Arcanus.xcodeproj

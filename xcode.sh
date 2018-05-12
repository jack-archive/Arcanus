#!/bin/bash

swift package update
swift package generate-xcodeproj
open ./Hearthstone.xcodeproj

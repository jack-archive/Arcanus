#!/bin/bash

swiftformat                         \
    --allman false                  \
    --wraparguments afterfirst      \
    --wrapelements afterfirst       \
    --self insert                   \
    --header ignore                 \
    --binarygrouping 4,8            \
    --octalgrouping none            \
    --indentcase false              \
    --trimwhitespace always         \
    --decimalgrouping 3,6           \
    --patternlet hoist              \
    --commas inline                 \
    --semicolons inline             \
    --indent 4                      \
    --exponentcase lowercase        \
    --operatorfunc spaced           \
    --elseposition same-line        \
    --empty tuple                   \
    --ranges nospace                \
    --hexliteralcase uppercase      \
    --linebreaks lf                 \
    --hexgrouping none              \
    --comments ignore               \
    --ifdef noindent                \
    --stripunusedargs closure-only  \
    .

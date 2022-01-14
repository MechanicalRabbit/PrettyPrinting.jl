#!/usr/bin/env julia

using PrettyPrinting
using NarrativeTest

default = [relpath(joinpath(dirname(abspath(PROGRAM_FILE)), "../docs/src"))]
runtests(default=default)

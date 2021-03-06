#!/usr/bin/env bash
set -o nounset
set -o pipefail

readonly OUTPUT="temp_compilation_output.tmp.txt"

if timeout -s 9 30 rustup run nightly-2020-10-22 rustc --crate-type=staticlib -C debuginfo=2 -C opt-level=z -C target-cpu=skylake "${INPUT}" &> "${OUTPUT}" ; then 
  exit 1
fi

if ! grep --quiet --fixed-strings "error: internal compiler error: compiler/rustc_trait_selection/src/traits/object_safety.rs:454:33: error: the type \`[type error]\` has an unknown layout" "${OUTPUT}" ; then
  exit 1
fi

if ! grep --quiet --fixed-strings "thread 'rustc' panicked at 'Box<Any>', compiler/rustc_errors/src/lib.rs:945:9" "${OUTPUT}" ; then
  exit 1
fi

if ! grep --quiet --fixed-strings "note: the compiler unexpectedly panicked. this is a bug." "${OUTPUT}" ; then
  exit 1
fi
exit 0

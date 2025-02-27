#!/bin/bash

matrix_includes=()

if [[ -n "$AGENT_PUBLISH" ]]; then
  matrix_includes+=('{"product": "agent"}')
fi
if [[ -n "$CONSOLE_PUBLISH" ]]; then
  matrix_includes+=('{"product": "console"}')
fi
if [[ -n "$GATEWAY_PUBLISH" ]]; then
  matrix_includes+=('{"product": "gateway"}')
fi
if [[ -n "$LOADGEN_PUBLISH" ]]; then
  matrix_includes+=('{"product": "loadgen"}')
fi

# if not triggered by workflow_dispatch, include all products
if [[ "$GITHUB_EVENT_NAME" != "workflow_dispatch" ]]; then
   matrix_includes=()
   matrix_includes+=('{"product": "agent"}')
   matrix_includes+=('{"product": "console"}')
   matrix_includes+=('{"product": "gateway"}')
   matrix_includes+=('{"product": "loadgen"}')
fi

echo "[$(IFS=,; echo "${matrix_includes[*]}")]"
#!/bin/bash

matrix_includes=()

# if not triggered by workflow_dispatch, include all products
if [[ "$GITHUB_EVENT_NAME" == "workflow_dispatch" ]]; then
  if [[ "$AGENT_PUBLISH" == "true" ]]; then
    matrix_includes+=('{"product": "agent"}')
  fi
  if [[ "$CONSOLE_PUBLISH" == "true" ]]; then
    matrix_includes+=('{"product": "console"}')
  fi
  if [[ "$GATEWAY_PUBLISH" == "true" ]]; then
    matrix_includes+=('{"product": "gateway"}')
  fi
  if [[ "$LOADGEN_PUBLISH" == "true" ]]; then
    matrix_includes+=('{"product": "loadgen"}')
  fi
else
  matrix_includes+=('{"product": "agent"}')
   matrix_includes+=('{"product": "console"}')
   matrix_includes+=('{"product": "gateway"}')
   matrix_includes+=('{"product": "loadgen"}')
fi

echo "[$(IFS=,; echo "${matrix_includes[*]}")]"
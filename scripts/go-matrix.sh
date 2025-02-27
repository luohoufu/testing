#!/bin/bash

matrix_includes=()

echo "$GITHUB_EVENT_NAME" "$AGENT_PUBLSH" "$CONSOLE_PUBLSH" "$GATEWAY_PUBLSH" "$LOADGEN_PUBLSH"

if [[ "${AGENT_PUBLSH:-true}" == "true" ]]; then
  matrix_includes+=('{"product": "agent"}')
fi
if [[ "${CONSOLE_PUBLSH:-true}" == "true" ]]; then
   matrix_includes+=('{"product": "console"}')
fi
if [[ "${GATEWAY_PUBLSH:-true}" == "true" ]]; then
  matrix_includes+=('{"product": "gateway"}')
fi
if [[ "${LOADGEN_PUBLSH:-true}" == "true" ]]; then
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
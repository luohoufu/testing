#!/bin/bash

matrix_includes=()

# if not triggered by workflow_dispatch, include all products
if [[ "$GITHUB_EVENT_NAME" == "workflow_dispatch" ]]; then
  if [[ "$AGENT_PUBLISH" == "true" ]]; then
    echo "Including agent"
    matrix_includes+=('{"product": "agent"}')
  fi
  if [[ "$CONSOLE_PUBLISH" == "true" ]]; then
    echo "Including console"
    matrix_includes+=('{"product": "console"}')
  fi
  if [[ "$GATEWAY_PUBLISH" == "true" ]]; then
    echo "Including gateway"
    matrix_includes+=('{"product": "gateway"}')
  fi
  if [[ "$LOADGEN_PUBLISH" == "true" ]]; then
    echo "Including loadgen"
    matrix_includes+=('{"product": "loadgen"}')
  fi
else
  matrix_includes+=('{"product": "agent"}')
  matrix_includes+=('{"product": "console"}')
  matrix_includes+=('{"product": "gateway"}')
  matrix_includes+=('{"product": "loadgen"}')
fi

# 使用 jq 生成有效的 JSON 输出
if [[ ${#matrix_includes[@]} -gt 0 ]]; then
  echo "${matrix_includes[@]}"
  jq -n --compact-output --argjson includes "[${matrix_includes[@]}]" '$includes'
else
  echo '[]'  # 如果数组为空，则输出空 JSON 数组
fi

exit 0
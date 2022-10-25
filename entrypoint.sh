#!/bin/bash
set -eu # Increase bash strictness

if [[ -n "${GITHUB_WORKSPACE}" ]]; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [[ "$(which flake8)" == "" ]]; then
  echo "[action-flake8] Installing flake8 package..."
  python -m pip install --upgrade flake8
fi
echo "[action-flake8] Flake8 version:"
flake8 --version

echo "[action-flake8] Checking python code with the flake8 linter and reviewdog..."
exit_val="0"
flake8 . ${INPUT_FLAKE8_ARGS} 2>&1 | # Removes ansi codes see https://github.com/reviewdog/errorformat/issues/51
  reviewdog -f=flake8 \
    -name="${INPUT_TOOL_NAME}" \
    -reporter="${INPUT_REPORTER}" \
    -filter-mode="${INPUT_FILTER_MODE}" \
    -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
    -level="${INPUT_LEVEL}" \
    ${INPUT_REVIEWDOG_FLAGS} || exit_val="$?"

if [[ "${exit_val}" -ne '0' ]]; then
  exit 1
fi

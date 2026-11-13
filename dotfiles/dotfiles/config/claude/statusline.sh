#!/usr/bin/env sh

# This script outputs the Claude status line

jq --raw-output '[
    "\(.model.display_name) (effort: \(.effort.level))",
    (.workspace.current_dir | sub("/home/dl"; "~")
        | sub(".*(?<end>(/.+){3})$"; "*\(.end)")),
    "Context: \((.context_window.used_percentage | select(. != null)
        | "\(. | round)%") // "None")",
    "Wait time: \(.cost.total_api_duration_ms / 1000)s",
    (.workspace.git_worktree | select(. != null) | "Worktree: \(.)")
] | join(" | ")
'

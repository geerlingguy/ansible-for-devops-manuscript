#!/bin/bash
# Count all lines in .txt files in a repository for each commit.
for commit in `git rev-list --all`; do
    git log -n 1 --pretty=%ad --date=short $commit
    # On GNU tar, add `--wildcards --no-anchored` options
    git archive $commit | tar -x -O '*.txt' | wc -w
done

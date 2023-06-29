#!/bin/bash
# Count all lines in .txt files in a repository for each commit.
for commit in `git rev-list --all`; do
    commit_date=$(git log -n 1 --pretty=%ad --date=iso-strict $commit)
    # On GNU tar, add `--wildcards --no-anchored` options
    wordcount=$(git archive $commit | tar -x -O '*.txt' | wc -w | xargs)
    echo "$commit_date,$wordcount"
done

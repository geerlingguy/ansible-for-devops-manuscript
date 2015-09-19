#!/bin/bash
# Count all lines in .txt files in a repository for each commit.
for commit in `git rev-list --all`; do
    git log -n 1 --pretty=%ad --date=short $commit
    git archive $commit *.txt | tar -x -O | wc -w
done

#!/bin/bash

# See: http://stackoverflow.com/a/9247215/100134
for commit in `git rev-list --all`; do
    git log -n 1 --pretty=%ad --date=short $commit
    git archive $commit *.txt | tar -x -O | wc -w
done

#!/bin/sh

currentbranch() {
    branch_name=$(git symbolic-ref -q --short HEAD)
    branch_name=${branch_name:-HEAD}
    echo $branch_name
}

currentbranch

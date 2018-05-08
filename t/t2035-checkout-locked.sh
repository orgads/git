#!/bin/sh

test_description='checkout must be able to overwrite open files'
. ./test-lib.sh

test_expect_success 'setup' '

	test_commit hello world &&
	git branch other &&
	test_commit hello-again world
'

test_expect_success 'checkout overwrites file open for read' '

	git checkout -f master &&
	exec 8<world &&
	git checkout other &&
	exec 8<&- &&
	git diff-files --raw >output &&
	test_must_be_empty output
'

test_expect_success 'checkout overwrites file open for write' '

	git checkout -f master &&
	exec 8>>world &&
	git checkout other &&
	exec 8>&- &&
	git diff-files --raw >output &&
	test_must_be_empty output
'

test_expect_success 'subdir' '

	git checkout -f master &&
	mkdir -p dear &&
	test_commit hello-dear dear/world &&
	git branch other-dir &&
	git mv dear cruel &&
	test_commit goodbye cruel/world
'

test_expect_success 'subdir checkout overwrites file open for read' '

	git checkout -f master &&
	exec 8<cruel/world &&
	git checkout other-dir &&
	exec 8<&- &&
	git diff-files --raw >output &&
	test_must_be_empty output
'

test_expect_success 'subdir checkout overwrites file open for write' '

	git checkout -f master &&
	exec 8>>cruel/world &&
	git checkout other-dir &&
	exec 8>&- &&
	git diff-files --raw >output &&
	test_must_be_empty output
'

test_done

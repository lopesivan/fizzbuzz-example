# Mr. Anderson's Magical Makefile!
# Check the README.md for usage instructions.

# Use bash as the execution shell, not sh.
CC=clang -std=c11
CFLAGS=-g -Wall
SHELL := /bin/bash

# ========= #
# Variables #
# ========= #

# Copy the contents of "Mercurial Repository URL" here!
REPO_URL = 

# Unique identifier for this assignment.
# Example: sorber-threads
ASSIGNMENT = 

# Names the archive file; usually given in your project spec.
# Example: project2.tgz
PROJECT_ARCHIVE = 

# Command to use to make your PROJECT_ARCHIVE file. Make sure your command
# matches the archive you're trying to make!
# Default: tar -czf
ARCHIVE_COMMAND = tar -czf

# Names your local Mercurial repository folder. If something gets messed up
# with the repo, you can try deleting this folder and running `make handin`
# again.
# Default: .handin
LOCAL_HANDIN = .handin

# These are all the files that will get added to the submitted handin archive.
# The Makefile is always included anyway, so don't worry about it.
# Example: README *.c
HANDIN_FILES =

# These are settings for connecting to a lab machine.
# USER is your username, MACHINE is a lab machine (check the SoC motd for more
# of them), and TEST_DIRECTORY is where all testing happens (it's created in your
# home directory)
REMOTE_USER = robertu
REMOTE_MACHINE = joey24
REMOTE_TEST_DIRECTORY = magic-project-tests

# ====================== #
# YOU CAN MESS WITH THIS #
# ====================== #

# Called with just "make". Make sure it works!
default: test

# ===================== #
# DON'T MESS WITH THESE #
# ===================== #

# Connects to a lab machine, copies the current directory over, and runs your
# remote tests.
remote:
	@echo ">> Copying current directory to the lab... <<"
	@rsync --exclude=".git" --exclude="$(LOCAL_HANDIN)/" --delete-delay -r . \
		--rsync-path="mkdir -p ~/$(REMOTE_TEST_DIRECTORY)/$(ASSIGNMENT) && rsync" \
		$(REMOTE_USER)@access.cs.clemson.edu:~/$(REMOTE_TEST_DIRECTORY)/$(ASSIGNMENT)/
	@echo ">> Executing \"make labtest\"... <<"
	@ssh $(REMOTE_USER)@access.cs.clemson.edu "ssh $(REMOTE_USER)@$(REMOTE_MACHINE).cs.clemson.edu \"\
	  cd ~/$(REMOTE_TEST_DIRECTORY)/$(ASSIGNMENT) && make labtest;\
	\""

# Connects to a lab machine and calls "make" on whatever you submitted last.
handout:
	@echo ">> Connecting to a lab machine... <<"
	@ssh $(REMOTE_USER)@access.cs.clemson.edu "ssh $(REMOTE_USER)@$(REMOTE_MACHINE).cs.clemson.edu \"\
	  echo '>> Connected! Cleaning old code... << ';\
	  rm -rf $(REMOTE_TEST_DIRECTORY)/$(ASSIGNMENT)-handin;\
	  echo '>> Cloning from handin... << ';\
	  hg -q clone $(REPO_URL) $(REMOTE_TEST_DIRECTORY)/$(ASSIGNMENT)-handin && \
	  echo '>> Unpacking and running \"make\"... <<';\
	  cd $(REMOTE_TEST_DIRECTORY)/$(ASSIGNMENT)-handin && tar -xzf $(PROJECT_ARCHIVE) && make\
	\""

# Arranges for files to be packaged into an archive, and pushes to the
# remote handin repo. Snazzy!
handin: $(HANDIN_FILES) Makefile
	@echo ">> Working on local repository... <<"
	@test -d $(LOCAL_HANDIN) || hg --quiet clone $(REPO_URL) $(LOCAL_HANDIN)
	@echo ">> Archiving project files... <<"
	$(ARCHIVE_COMMAND) $(LOCAL_HANDIN)/$(PROJECT_ARCHIVE) $^
	@echo ">> Submitting project to handin... <<"
	@hg files --cwd $(LOCAL_HANDIN) -I "$(PROJECT_ARCHIVE)" &>/dev/null || hg --quiet --cwd $(LOCAL_HANDIN) add $(PROJECT_ARCHIVE)
	@hg --quiet --cwd $(LOCAL_HANDIN) commit -m "Submitted new project version"
	@hg --quiet --cwd $(LOCAL_HANDIN) push
	@echo ">> Success! Use \"make handout\" to test on a lab machine. <<"

# ============ #
# ADJUST THESE #
# ============ #
# You probably don't want to change the rules' names
# too much, but you can adjust their dependencies and what they do.

# Indicates that these special rules aren't for files (they're for doing cool things)
.PHONY: all test labtest remote handout handin \
	clean

# Cleans out old code
clean:
	@echo "Nothing to clean. Update the \"clean\" rule!"

# Executing "make remote" will run this rule on a lab machine.
labtest:
	@echo "Nothing to execute. Update the \"labtest\" rule!"

# Run with just "make". Should compile things but run nothing.
all: fizzbuzz
	

# Run with "make test". Best test everything!
test: fizzbuzz
	bats -t tests.bats

# =============================== #
# PUT YOUR CUSTOM MAKE RULES HERE #
# =============================== #
# Then you can reference them above.
fizzbuzz: fizzbuzz.c

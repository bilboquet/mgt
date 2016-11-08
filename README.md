# mgt
A distributed task management tool.

# Dependencies
`mgt` is written in `Bash` shell and rely on `git` for: storage, history management and sharing / publishing projects and tasks.

# Getting starded
1. Install (see bellow)
2. Initiate a local repository: `mgt init -n`
3. Create a project: `mgt project init my_mgt_project`
4. Start adding task to project:
```
mgt task add -c todo -d "my first task"
mgt task add -c todo -d "my second task"
```

In any case `Bash` completion is provided and should help.
`mgt -h` or `mgt <command> -h` is also very helpfull.

# Install
`git clone https://github.com/bilboquet/mgt.git mgt && cd mgt && make install`

# Uninstall
`[git clone https://github.com/bilboquet/mgt.git mgt &&] cd mgt && make uninstall`
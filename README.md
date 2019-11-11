# gstatus

A pretty `git status` command line tool. It feels bloated with a lot of useless text and the `--short` option doesn't give as much information...

I wrote this script mostly to learn shell scripting as well as to improve my knowledge on git command line tools.

![gstatus in action!][demo]
Note: I use _Fira Code_ with font ligatures enabled and _Font Awesome_.

As you can see in the screenshot, `gstatus` is a pure eyes candy tool. It shows the current branch and its status compared to upstream but also compared to other remotes. The working tree status is displayed through the `git status --short` command as well as the stash status with the `git stash list` command (stashes aren't themed yet so I didn't show them in the screenshot).


# Install

I suggest you drop the script into your `~/bin`.

# Usage

For now there is no option... So:

```sh
$ gstatus
```

You can configure the style for every fields displayed by editing the global variables at the beginning of the script. (You can also use these variables to add nice icons from unicode, fontawesome, emojis, ..., like I did on the screenshot. The default configuration uses Font Awesome icons.)


(Screenshot generated on https://carbon.now.sh)

[demo]: imgs/screenshot.png "gstatus in action!"

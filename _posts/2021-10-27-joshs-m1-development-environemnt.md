---
title: "Josh's M1 Mac Development Environment - homebrew, zsh, Ruby and python version managers"
layout: post
date: 2021-10-27 7:30:00
image: /images/2021-10-27/header.png
headerImage: true
tags:
- shortcuts
category: blog
author: joshdholtz
description: This is the setup I'm using on my M1 Mac (and Rosetta) to handle homebrew, zsh, Ruby and python version managers
---

Hello, it's me! Josh Holtz. On my [joshholtz.com](https://joshholtz.com) blog. I don't know who else it would be 😅

This post will briefly show how I have my M1 Mac setup to handle homebrew, zsh, Ruby and Python version managers and how they all interact with Rosetta 💪

TL;DR - The problem was not homebrew or any other tools. I was my weird setup and misunderstanding of how M1 and Rosetta worked 🤷‍♂️

## The YouTube Format

There is a YouTube format of this blog post on my [YouTube channel](https://youtube.com/joshdholtz) over at [https://youtu.be/EG-K5n20_HQ](https://youtu.be/EG-K5n20_HQ) 👀	

## The Problem

I was having mad issues with my develoment environment. Ruby was having issues installing native extensions. Homebrew was having more and more issues installing dependencies for unknown reasons (to me).

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Me, M1, and homebrew are just not getting along… again 😭</p>&mdash; Josh “so many typos” Holtz 💪🚀 (@joshdholtz) <a href="https://twitter.com/joshdholtz/status/1450495076644368391?ref_src=twsrc%5Etfw">October 19, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

After a day or two of constantly uninstalling and reinstalling homebrew and my other tools, I figured out my issue and my development environment that I wanted to use going forward.

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">OMG, I finally figured out how to get my M1, homebrew, and Rubies playing nicely 😅<br><br>Would anybody like a blog post or video tutorial on how to do this? 🙃</p>&mdash; Josh “so many typos” Holtz 💪🚀 (@joshdholtz) <a href="https://twitter.com/joshdholtz/status/1450501347908984838?ref_src=twsrc%5Etfw">October 19, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

It turns out... the root cause of my problem was I was using a build of [Alacritty](https://github.com/alacritty/alacritty) (a terminal ) that was built for Intel so all of my stuff was running in Rosetta without me knowing 🤦‍♂️

<hr/>

## Being cognizant of architecture

I would have solved my issues a lot sooner if I knew what architecture my terminal was running in. The options being `arm64` or `i386`.

### Zsh prompt

So the first thing I did was add the architecture my terminal was running in into my Zsh prompt. The prompt is the thing the shows before your cursor when you are in a terminal. My prompt already shows the directory I'm in and the git branch of the directory (if I'm in a git repo). I thought it would be cool to also prefix that with the architecture!

This can be done with a custom theme. I was using the `robbyrussel` theme so I based the `joshdholtz` theme off of that 💪

Create `~/.oh-my-zsh/themes/joshdholtz.zsh-theme` 👇

```sh
PROMPT="%(?:%{$fg_bold[green]%}➜ $(arch) :%{$fg_bold[red]%}➜ )"
PROMPT+=' %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
```

I modified my `~/.zshrc` with `ZSH_THEME=joshdholtz` 👇

```sh
ZSH_DISABLE_COMPFIX=true
export ZSH="/Users/joshholtz/.oh-my-zsh"

# joshdholtz theme shows arch type in the prompt
ZSH_THEME="joshdholtz"
plugins=(git)
source $ZSH/oh-my-zsh.sh
```

### Switching between M1 (arm64) and Rosetta (i386)

It's important to have a terminal that can run in Rosetta (i386) so that you can build/compile/install things that aren't able to run on M1 yet. A lot of the suggestions I've gotten were to copy `Terminal.app` and rename it to `Rosetta-Terminal.app`, click the "Get Info", and check the `Run in Rosetta` box.

I don't like this approach (for me) because I don't want to have multiple Terminal open that look the exact same. And I don't expect myself to _always_ be in Rosetta mode. Only when I need it. So I found a way switch my current terminal session using `arch --arm64 zsh` and `arch --x86_64 zsh`. These command essentially replace my current Zsh session with one running in the architecture of my chooseing. I used these often enough where I aliased them `mzsh` (M1/arm64) and `ishz` (Rosetta/i386). You can see my `.zshrc` below where I alias these commands.

```sh
alias mzsh="arch -arm64 zsh"
alias izsh="arch -x86_64 zsh"
```

### Separate homebrews

The next thing was to have Homebrew installed in M1 and in Rosetta. Homebrew works a little bit differently because M1 Homebrew is installed at in the `/opt` directory where Rosetta Homebrew is installed in the `/usr/local` directory. 

To handle this for M1, the ran the Homebrew install script in my `mzsh` session.
To handle this for Rosetta, I ran the Homebrew install script in my `izsh` session.

The tricky part is to re-alias the `brew` command to point at the correct Homebrew install depending on which architecture you are running in. There is a switch for this **also** in my `.zshrc`

```sh
if [ "$(uname -p)" = "i386" ]; then
  echo "Running in i386 mode (Rosetta)"
  eval "$(/usr/local/homebrew/bin/brew shellenv)"
  alias brew='/usr/local/homebrew/bin/brew'
else
  echo "Running in ARM mode (M1)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  alias brew='/opt/homebrew/bin/brew'
fi
```

### Installing Ruby (and other) version managers

Knowing that you are in the correct architecture is key for installing other tools (like version managers).

#### ruby-install and chruby

My *personal* favorite Ruby version manager is `ruby-install` and `chruby`.

```sh
brew install ruby-install
brew install chruby
# put stuff in path in ~/.zshrc that chruby instructions tell you to
ruby-install 3.0
source ~/.zshrc
chruby 3.0
```

#### asdf

My next suggestion would be to use `asdf`. `asdf` is a complete version manager for multiple runtimes. I use it for Ruby, Python, and NodeJS but it has more.

```sh
brew install asdf
# put some stuff in path in ~/.zshrc that asdf instructions tell you to
asdf plugin add ruby
asdf install ruby latest
asdf global ruby latest
```

### But why separate Homebrew installs?

Great question! Most things (that I use) through Homebrew will work perfectly fine on M1 (arm64). However, there are some tools that you need to compile or install that won't work. We can test this out with Python 2.7.18. Running `asdf install python 2.7.18` will fail due to architecture issues on M1. But if you change to Rosetta (using `izsh`) and run `asdf install python 2.7.18`, it will succeed 🥳 And now that Python 2.7.18 is compiled and installed from Rosetta, you can actually use it when you are back in M1 (arm64). Just switch back over with `mzsh` and run `python` you will see! (But don't forget to run `asdf global python 2.7.18` or `asdf local python 2.7.18` first).

Why does this work on M1 (arm64) even though you needed Rosetta for it? Well... here is my understanding of it 😇 Jumping into Rosetta to compile and install it essentially makes an M1/arm64 installation of it _after_ it compiles in the i386 architecture. The M1 Mac don't have an Intel processor so everything needs to get to an M1 format somehow. So with this above example, we only need Rosetta for the compile and install phase. Now Python 2.7.18 will work anywhere for us!

## The End

So yeah, that's it I think for this post! I just wanted to share my Zsh setup that makes it easy for me to use my M1 and have confidence in building and installing different tools between M1 (arm64) and Rosetta (i386) 😁 I may have some things explained wrong since I wrote this SUPER QUICKLY but hopefully this helps some of you out 🙏

Feel free to tweet me ([@joshdholtz](https://twitter.com/joshdholtz)) or email me if you have any feedback or questions about this. Thanks for reading and happy Shortcutting!

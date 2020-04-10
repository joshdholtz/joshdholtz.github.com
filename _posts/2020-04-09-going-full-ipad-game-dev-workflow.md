---
title: Going Full iPad - Game Dev Workflow
layout: post
date: 2020-04-09 23:30:00
image: /assets/images/markdown.jpg
headerImage: false
tags:
- ipad
- game dev
category: blog
author: joshdholtz
description: 
---

# Going Full iPad: Game Dev Workflow with LÖVE

It’s week four (I think) of sheltering at home and I was starting to get a little bit stuck in a rut. I’ve been working remote from my home office for four years and I usually don’t have a many problems. Whenever I need a change of pace I would often go to one of my favorite coffee shops. But, it is currently not possible to go to coffee shops since a majority of them closed due to COVID-19. I needed a change to get me out of this rut. I choose to go forgo sitting at my Mac mini in my home office and commit to using my iPad full time 😈.

_I will release a blog post next week of my thoughts, feelings, and discoveries of using iPad full time. This post is about my workaround workflow for doing game development “on” my iPad_

## Project Background

In February of this year (2020), I started working on a game I’ve always wanted it make — the perfect fishing game. Fishing is one of my favorite side activities in video games. But there is no game that takes that side quest and turns it into the main story. I contemplated starting this game myself for many months. In February I created “Grandpa Kenny’s Fishing Adventure” in [LÖVE](https://love2d.org). LÖVE is a 2D gaming framework using Lua. My plan was to develop this as a desktop game on macOS, Windows, and Linux. I found out that LÖVE made it easy to also provide an iOS and Android version. The iOS project the LÖVE provides works out of the box with very few changes needed. The major thing the iOS project needed was a `.love` file for your game.

A `.love` file is a zip file of source directory but with a “love” extension instead of a “zip” extension. The source directory contains all the Lua files and assets. This `.love` file then gets fused into iOS project my placing it into the bundle resources. The coolest thing about the LÖVE iOS project is that you don’t need to fuse in the `.love` file to play your game. The LÖVE iOS app allows dragging and dropping of `.love` files. The app will display a list of all the LÖVE games in the apps “Documents” directory. This is a very quick and easy way to test new versions of your game. The alternative is to compile the iOS project over and over again. All you need to do is keep the simulator open and drop in your `.love` files to test your game.

This ability to drag in files into the LÖVE iOS app is the foundation of my discovered workaround 😇

## Game Dev Workflow on macOS

My game dev workflow for LÖVE on macOS was quick and simple. I execute `love ./source` in my CLI and the game loads in a new window right away. There is a problem when trying to use this workflow from my iPad though. This would requires me spend most of my time remoted into my Mac . I do love using [Jump](https://jumpdesktop.com) as my VNC client but it shouldn’t be my primary tool when working on my iPad.

## Game Dev Workflow on iPad

Even though I didn’t want to use VNC on my iPad, I’m happy to use SSH or Mosh with [Blink](https://blink.sh). All my LÖVE development I do on my Mac mini is within full screen terminal using Vim. I was hoping to find a solution which allowed for a similar experience. I want to use my terminal until its time to actually test the tame.

_The following solutions assume I’m already connect on my Mac mini with Blink (I use Mosh now but SSH also works)_

### First Solution: Compile, Sign, and Install Wirelessly

The first solution I thought of was not great. I knew that it would be slow but I wanted to get something working.

1. Build and sign IPA with _fastlane_
2. Install on device with _fastlane_’s action `install_on_device`

It worked! 🥳 But it also took about a little less than 10 minutes for the compile, sign, and install. This was not acceptable to me. The 10 minutes can completely kill any creative thoughts and focus that I need to keep. This solution also made me _not_ want to use my iPad anymore go back to my desk to use my Mac mini.

### Second/Final Solution: Accept Shared `.love` Files

As mentioned earlier, the LÖVE iOS app allows for dragging and dropping of `.love` files in the simulator. This meant that the app got something else for free. My iOS app would appear as share option `.love` files in the iOS _Files_ app!

Knowing this I had to find a easy way to transfer my `.love` file from my Mac mini to iPad for me to install. My original thought was to use SFTP to save onto my iPad but that didn’t seem like a very iPad solution. I then realized I didn’t need to create a new link between my Mac mini and my iPad. They already had a connection through iCloud Drive. I first created a new folder in iCloud Drive for my `.love` files.  I manually moved a `.love` file from my development directory into iCloud Drive’. When I clicked “Share”, my LÖVE iOS app opened but my game file did not appear in the list.

_I thought this was going to work for me right away._

I did some debugging by VNC-ing into my Mac mini. I downloaded my iOS app’s container from my iPad through Xcode onto my Mac mini. This allowed me see where the app saved `.love` files. It turned out the files were not in the `Documents` directory (which is where the app wanted them). They instead were in the `tmp/<bundle_id>-Inbox` directory.

_This wasn’t bad though! I could work with this._

I made some changes to the LÖVE iOS app. I added logic to move any `.love` files from the temporary directory to the `Documents` directory. And that was it! I installed these changes to my iPad from Xcode over the air. I went back to the _Files_ app to open my `.love` file into the iOS app and my game appeared in the list!

_Now it's time to script this out to make it easier._

I use [fastlane](https://docs.fastlane.tools) to make and distribute builds for all platforms of my project. So it made sense that I also use _fastlane_ to do this. Below is the lane I wrote to zip the source and move it over to iCloud Drive with a `.love` extension.

```ruby
lane :to_icloud do
  # Zip source
  zip_path = File.join(Dir.tmpdir, "game.zip")
  FastlaneCore::Helper.zip_directory("../source", zip_path.shellescape,
                                     contents_only: true, 
                                     overwrite: true,
                                     print: false)

  # Generate path of .love file in iCloud Drive
  icloud_dir = File.expand_path("~/Library/Mobile Documents/com~apple~CloudDocs/fishing-adventure")
  love_file_name = "game-#{Time.new.strftime("%Y-%m-%d-%H%M")}.love"
  love_path = File.join(icloud_dir, love_file_name)

  # Copy from tmp to iCloud Drive
  FileUtils.mv(zip_path, love_path)
end
```

The finalized solution was this:

1. Run `fastlane to_icloud`
  2. Zips the source directory
  3. Rename with `.love` extension
  4. Moves it into iCloud with 
2. Open up the _Files_ app
3. Find my new game file and share into my iOS app
4. Open up the game, refresh the list, play my game

Below is a screen recording of the results 🥰

<video width="100%" poster="/images/love2d_ios_screen_recording_poster.png" controls>
  <source src="/images/love2d_ios_screen_recording.mp4" type="video/mp4">
Your browser does not support the video tag.
</video>



This new workflow ended up taking only about 20 or 30 seconds! That is a huge drop from the 10 minutes my initial attempt took. This workflow could be easier if I spent some time to make something with _Shortcuts_ but I did not get that far yet.

## So Was This All Worth It?

Its still faster to do development on my Mac mini. But I don’t always want to be sitting at my desk or forced to use VNC when I”m not. I want to roam round my house and yard and still be able to develop. Getting this process down to only 20 to 30 seconds on my iPad is a win for me. It was a fun problem to solve with a simple and creative solution.

I’m still crossing my fingers that one of these WWDCs will have news about doing development on the iPad. In the meantime, I’m looking forward to problem solving development solution on my iPad 😊

---
title: "Launch Announcement: Oh Crop for iOS"
layout: post
date: 2021-06-01 7:30:00
image: /images/2021-06-01/marketing-1.jpeg
headerImage: true
tags:
- indie
- oh-crop
- annoucement
category: blog
author: joshdholtz
description: iOS app for cropping photos to the shape of emojis
---

I’ve teased this app for about a month now. I even made [a teaser for a teaser](https://twitter.com/joshdholtz/status/1388148055124463617) which I was slightly embarrassed by it seemed like something fun to try 🙈 But today is the day…

**Happy launch day, Oh Crop!** 🥳

<a href="https://apps.apple.com/us/app/oh-crop-emoji-but-as-photos/id1563845967" target="_blank">
  <img src="/images/Download_on_App_Store.svg"/>
</a>

<hr/>

## _What is Oh Crop?_

**Oh Crop** is my latest iOS app that will crop a photo to look like an emoji either in-app or through a Shortcut action 👇

<img src="/images/2021-06-01/josh_heart.png" width="200">
<img src="/images/2021-06-01/josh_wave.png" width="200">
<img src="/images/2021-06-01/josh_crab.png" width="200">
<img src="/images/2021-06-01/josh_snow.png" width="200">

## _Why did you make Oh Crop?_

It was an accident 🤷‍♂️ It was initially meant to be nothing more than an empty app that had an iOS Shortcut for cropping an image to a circle. I needed this for automating my processes around preparing, writing, and releasing new [Indie Dev Monday](https://indiedevmonday.com) issues.

Indie Dev Monday is my newsletter that spotlights one or two indie developers every week. The issue contains a profile picture of the indie developers -- which I usually pull from Twitter -- that gets displayed in both the web version and the email version of the newsletter. The easiest way to have a consistent look between the two versions was to create a circle version of the photo. The first few issues were cropped manually through some tool but I eventually wrote a small Ruby script to download and crop the photo to a circle.

This process was _technically_ working fine but it required that I always had access to my Mac for preparing and releasing issues. This was okay until I became a parent in December of 2020 🥰 Since then, a majority of my issues have been prepped, written, and released from my iPhone -- as it was easier to use a phone while walking or rocking a baby than awkwardly using a computer 😛  Even though I was doing this all through my phone, I still had to remote into my Mac to run my automation scripts. I didn’t like having to do that so I decided I want to move everything to iOS Shortcuts.

I had no trouble converting my scripts to Shortcuts and the majority of the Shortcuts used built-in actions provided by iOS. The one action I was struggling to find was cropping an image into a circle. I didn’t have any existing apps installed that could do it and I couldn’t easily find an on the App Store that could do it…

**So I decided to make my own 😜**

I like to take odd approaches when solving problems. I get a thrill from solving problems (even if the problems are self-inflicted). Cropping an image to a circle is pretty trivial when writing an in iOS… But I wanted to have some fun 😈

## _What was the solution_?

Instead of using code to crop the circle, I decided it would "cool" to use the circle emoji (🔴) to crop the circle.

The steps to do this ended up being:
1. Find the font size needed for the emoji to fill the photo
2. Convert emoji from text into an image
3. Use the emoji image as a mask against an all-white image to create an inverted emoji mask
4. Use the inverted emoji mask against the user-provided photo

The result of this is a photo that looks like the emoji used 😁 In this case… it was just an over-engineered circle.

From there, I decided to try out some other emoji shapes that people might like or use  🟥, 🔷, or ❤️. But then I started to wonder what using other emojis would look like…

The 🐩, 🚽, or 🗑 were some of the first that I used! But I wanted to try them all. My wife and I spent unknown amounts of time trying out all of the emojis 😛 It was hard to pick a favorite because different kinds of photos look better (and worse) with different emojis.

At this point there no functional app and no plans to release the app. It could crop photos to any emoji but I using it only with iOS Shortcuts to crop a photo to a circle with the 🔴 emoji for my Indie Dev Monday issues.

## _Why did you want to release this app?_

Straight up… I wasn’t planning on releasing this at all. I made this app to solve my needs and that is all I wanted from it.

The only reason that pushed me over the edge was how much of a pain it to keep a non App Store version of an app on my phone 😛 It requires the app to be installed as a development build (installed directly through Xcode to my phone) or as a beta app through TestFlight.

The problem with the development build is that it requires valid certificates and provisioning profiles through my Apple developer account. This would be fine if I wasn’t mean to my account 🙃 Because of the nature of my day job (maintaining [fastlane](https://fastlane.tools)), I will often revoke all of my certificates and delete my provisioning profiles. This is fine (for me) unless I have a development build of an app on my devices. When the certificate is revoked or the profile is deleted, the app will no longer run. The only way to get it to run again is to recreate the certificate and profile and manually install a new build. I’m too lazy for that…

Distributing the app as a beta app through TestFlight won’t have any side effects from revoking and deleting certificate and provisioning profile issues but the app version submitted to TestFlight _will_ expire after 90 days. I didn’t want to have to keep uploading new builds just to keep the app alive.

**So the only logical thing to do is launch the app on the App Store 😅**

However, I have a rule where I won’t launch an app unless it has a good name (which should be a pun) and good looking app icon. On top of this, I also want to use app launches (even for small apps like this one) as a practice ground for leveling up my marketing skills (websites, press kits, graphics, videos, etc).

## _How did this become Oh Crop?_

I needed a name, app icon, and a concept to make this interesting enough to release on the App Store. And the way I got this name is slightly embarrassing. The name "Oh Crop" hit me while I was walking into a bathroom 🤦‍♂️ 

1. The app was meant for cropping circles so the "Oh" sounds like "O" which looks like a circle 
2. "Oh Crop" sounds like the phrase "Oh Crap" which made me giggle ☺️
3. Because of the "Oh Crap" reference, I could make the app icon a really cute version of the 💩 emoji

With the app name and icon figured out, the next steps were to bring "Oh Crop" and "Oh Crap" into the app itself. I wanted to add a level of fun to the app but also something that wasn’t _too_ much work for either me as the developer or the user.

**What if… the user could randomly get a 💩 emoji instead of the one this asked for?**

I started to hard fall in love with this idea. It was easy to implement and played really well into the "Oh Crop" and "Oh Crap" 😁 Ideas for this started coming fast. This was no longer just an iOS Shortcut app.

I first added a label that showed what odds of success the user had when picking an emoji for their photo. The success rate is based on a random number generator seeded from the day so that it's the same for every user each day. From here I create a new screen where the user can see a 7-day forecast of the success odds. Users can use this to find the day they had the best chances to successfully crop to emojis.

This decision to have random 💩 emojis backfired when I tried to release a new issue of Indie Dev Monday a few weeks ago. I almost released an issue with a 💩 shaped profile picture of one of my indie devs 😂 After that I decided to add an in-app purchase to unlock the ability to disable the 💩. 

After that there was one night where I couldn’t sleep… so I decided to add widgets. I first added a single widget to view the 💩 chance percent. That wasn’t enough so I also added a 7-day forecast widget to go with it. At this point, the app itself still didn’t feel like it had enough substance to it. I wasn’t going to crop photos every day but I wanted to see some of the fun croppings that I created. I added a "widget album" feature. The user can create albums of emojis and photos. A widget can be configured to show a certain album and would rotate through random emoji and photo combinations.

This app was only meant to be an iOS Shortcut that could crop photos to circles. And now that plus this emoji cropper and emoji photo widget thingy. I think after that is where I decided I needed to stop and release this 🤷‍♂️

## _Here are we_

This app isn’t meant to be a serious app. This isn’t meant to be an app that I can make a living off of. This isn’t an app that everyone will enjoy. This app wasn’t ever meant to be used by anybody else.

The result of this accidental app creation was the most inefficient and over-engineered way of cropping an image to a circle. But I don’t care because I had fun making and release this app! Being able to create things like this is why I’m a developer ❤️ 

Thanks for reading my story about **Oh Crop** and I hope that some of you enjoy using this app! 

Feel free to tweet me ([@joshdholtz](https://twitter.com/joshdholtz)) or [@OhCropTheApp](https://twitter.com/OhCropTheApp) with any feedback, issues, or feature request🥳

<a href="https://apps.apple.com/us/app/oh-crop-emoji-but-as-photos/id1563845967" target="_blank">
  <img src="/images/Download_on_App_Store.svg"/>
</a>

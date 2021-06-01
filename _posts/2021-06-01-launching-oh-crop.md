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
description: The most okayest and minimalistic RSS reader on iOS and macOS
---

# Launch Announcement: Oh Crop for iOS

I’ve teased this app for about a month now. I even made [a teaser for a teaser](https://twitter.com/joshdholtz/status/1388148055124463617) which I was slightly embarrassed by it seemed like something fun to try 🙈 But today is the day…

**Happy launch day, Oh Crop!** 🥳

<a href="https://apps.apple.com/us/app/oh-crop-emoji-but-as-photos/id1563845967" target="_blank">
  <img src="/images/Download_on_App_Store.svg"/>
</a>

<hr/>

## _Why did you make Oh Crop?_

To be honest… the scope of this app got out of control quickly.

The original goal was to make an app with a Shortcut that could crop an image to a circle. That was it 🙃 I needed this for my automations for [Indie Dev Monday](https://indiedevmonday.com). I will write a more detailed blog post about this in the future but one of my automations will pull down profile pictures from Twitter for each of the spotlighted indie developers and saves them into my git repository with [Working Copy](https://workingcopyapp.com). I need the images to be cropped into a circle so I can use the same image for the web and the email version of the newsletter. I couldn’t _easily_ find an app that would crop an image into a circle

**So I decided to make my own 😜**

I like to take odd approaches when solving problems. I get a thrill from solving problems (even if the problems are self-inflicted). Cropping an image to a circle is pretty trivial in iOS. There are plenty of Stack Overflow posts that could have solved this in a few lines of code for me. But I wanted to have some fun 😈

## _What was the solution_?

Instead of using code to crop the circle, I decided it would "cool" to use the circle emoji to crop the circle. This one 👉 🔴.

The steps to do this ended up being:
1. Find the font size needed for emoji to fill the photo
2. Turn emoji string into an image
3. Use emoji image as a mask against an all-white image to create an inverted (negative) mask of the emoji
4. Use the inverted mask of the emoji as a mask against the actual photo 

The result of this is a photo that looks like the emoji used 😁 In this case… it was just a circle. But this opened up the doors to use any emoji!

I originally thought it could be interesting to maybe use this with 🟥, 🔷, or ❤️. But then I found that using 🐩, 🚽, or 🗑 was more fun! My wife and I spent a stupid amount of time trying to find the emojis that looked the most ridiculous with our photos 😛

There was no functional app and this point. The only functional thing was the Shortcut that came with the app. I used Shortcut to crop a photo with the 🔴 emoji for my Indie Dev Monday issues.

## _Why did you want to release this app?_

Straight up… I wasn’t planning on this at all and didn’t want to 😛 The main reason I decided to release this app to the App Store was that it’s a pain to keep a non App Store version of an app on my phone. The ways that I could have it installed on my phone:

1. Development build (installed through Xcode directly to my phone)
2. TestFlight build

The problem with the development build is that it requires that I don’t nuke my development certificates or invalidate my provision profiles. I ended up doing this quite often through the nature of my day job while maintaining [fastlane](https://fastlane.tools). The app will not open up when this happens. Distributing the app through TestFlight won’t cause any certificate or provisioning profile issues but the app will expire after 90 days. I don’t want to have to keep uploading new builds just to keep that app alive.

**So the only logical thing to do is launch the app on the App Store 😅**

I have a self rule where I won’t launch an app unless it has a good name (which should be a pun) and I good or stupid good app icon. I also want to use app launches (even for small useless apps) as a practice ground for leveling up my marketing skills (websites, press kits, graphics, videos, etc).

## _How did this become Oh Crop?_

I needed a name, app icon, and a concept to make this interesting enough to release on the App Store. And the way I got this name is slightly embarrassing. The name "Oh Crop" hit me while I was walking into a bathroom 🤦‍♂️ 

1. The app was meant for cropping circles so the "Oh" sounds like "O" which looks like a circle 
2. "Oh Crop" sounds like the phrase "Oh Crap" which made me giggle ☺️
3. Because of the "Oh Crap", I could make the app icon a really cute version of the 💩 emoji

This name caused the app concept to get out of control real fast. Because of the 💩 themed name and app icon, I could use the 💩 emoji concept in the app! I had the idea to gamify things a little bit where the user didn’t always get the emoji cropping they asked for. I thought it could be fun for the image to turn out looking like the 💩 emoji instead. So I added a feature where there are different odds of successful cropping each day. This then leads to a screen where it showed the 7-day forecast of the odds. Users could use this to find the day they had the best chances to successfully crop to emojis.

This decision to have random 💩 emojis backfired when I tried to release a new issue of Indie Dev Monday a few weeks ago. I almost released an issue with a 💩 shaped profile picture of one of my indie devs 😂 After that I decided to add an in-app purchase to unlock the ability to disable the 💩. 

There was one night where I couldn’t sleep so I decided to add widgets. I first added a single widget to view the 💩 chance percent. That wasn’t enough so I also added a 7-day forecast to go with it. At this point, the app itself still didn’t feel like it had enough substance to it. I wasn’t going to crop photos every day but I wanted to see some of the fun croppings that I created. I added a "widget album" feature. The user can create albums of emojis and photos. A widget can be configured to show a certain album and would rotate through random emoji and photo combinations.

**I think after that is where I decided I needed to stop and release this 🤷‍♂️**

This app was only meant to be an iOS Shortcut that could crop photos to circles. And now that plus this emoji cropper and emoji photo widget thingy.

## _Here are we_

The best/worst part is how inefficient this app is for its original purpose 😅 It much slower and takes more memory using the 🔴 emoji as a mask than cropping to a circle using APIs provided by iOS.

This isn’t meant to be a serious app. This isn’t meant to be an app that I can make a living off of. This isn’t an app that everyone will enjoy.

But I had fun making and releasing the app! That is the important thing to me ❤️ And I hope that some of you enjoy using this app! 

Feel free to tweet me ([@joshdholtz](https://twitter.com/joshdholtz)) or [@OhCropTheApp](https://twitter.com/OhCropTheApp) with any feedback, issues, or feature request🥳

<a href="https://apps.apple.com/us/app/oh-crop-emoji-but-as-photos/id1563845967" target="_blank">
  <img src="/images/Download_on_App_Store.svg"/>
</a>

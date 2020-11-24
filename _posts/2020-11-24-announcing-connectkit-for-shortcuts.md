---
title: "Launch Announcement: ConnectKit for Shortcuts"
layout: post
date: 2020-11-24 7:30:00
image: /images/2020-11-24/Hero.png
headerImage: true
tags:
- indie
- connectkit
- annoucement
category: blog
author: joshdholtz
description: The best way to use the App Store Connect API on iOS with easy to use Shortcut actions
---

**Today is the day!** I’m so excited to finally release this app. This app is a combination of a few of my passions: iOS, developer tools, and App Store Connect API.

**Happy launch day, ConnectKit** 🥳

<hr/>

## _What does ConnectKit do?_

ConnectKit securely stores App Store Connect API Keys and offers up actions in Shortcuts to make authenticated requests. To be honest, that probably does not sound that exciting... but it is to me!

<hr/>

## _Why did you make ConnectKit?_

I made ConnectKit because I have a love for developer tools and automation. This is probably already known though since I almost solely talk about about [fastlane](https://fastlane.tools). I’ve been actively working on _fastlane_ for 5+ years and I’ve been the lead maintainer of _fastlane_ for the past 2.5+ years and in that time I have spent **a lot** of time interacting with the iTunesConnect and App Store Connect APIs. The private APIs that _fastlane_ used were great for a CLI tool but could not have been moved into an iOS app. They were complex to use and would not have been approved by the App Store review.

But then WWDC 2018 happened! I was sitting front row in the automation session when the official App Store Connect API was announced. I knew this was going to change the game for _fastlane_ and everything else.

Fast forward to 2020 and the App Store Connect API has been implemented in _fastlane_. I fell deeply in love with it an wanted to do more things. I don’t know exactly when the idea for ConnectKit popped into my head but I think it was after I saw all the fun widgets and Shortcut apps that were being made after WWDC 2020. I knew I had to try this...

It combined my love for automation, iOS, and the App Store Connect API. I wasn’t sure my idea was against terms to store API Keys or if my app would be seen as a competitor to the Connect app and would be rejected but I had to try. It turns out it wasn’t an easy path as my app was “In Review” for 36 days but eventually got approved!

So that is _why_ I made ConnectKit but like... what does it do?!

<hr/>

## _What can ConnectKit do?_

Great question! ConnectKit allows for endless possibilities of automation querying and updating information from App Store Connect. ConnectKit takes the API Key and uses it to make a JSON Web Token (JWT) which is used for authorizing requests to the App Store Connect API.

There are so many endpoints that the App Store Connect API offers up:

- TestFlight
- Users and Roles
- Provisioning
- App Metadata
- Reporting
- Power and Performance Metrics

All of the endpoints in these categories can be found in the [App Store Connect API Docs](https://developer.apple.com/documentation/appstoreconnectapi).

ConnectKit helps iOS users bridge the gap to these App Store Connect API endpoints using Shortcuts.

ConnectKit includes one Shortcut action for free. This is the “Get JWT” action. It outputs a JWT valid for 20 minutes which can be used to make an authorized request using iOS’s built-in “Get Contents of URL” action. Pass this JWT in the `Authorization` header, set your URL to an App Store Connect API endpoint, and boom... you got yourself a JSON response that you can parse.

![Action Get JWT](/images/2020-11-24/action_get_jwt.jpg)

However, ConnectKit currently offers four premium actions but more are on the way! I’ve been holding off on implementing other actions since I wasn’t even positive if ConnectKit was going to pass App Store review 😇 The four premium actions are:
- Make Request
- Get Apps (and more coming like this)
- Get Finance Reports
- Get Sales Reports

### Make Request

This is a combination of “Get JWT” and “Get Contents of URL”. It’s totally magical but makes things a little bit cleaner when making Shortcuts. This method requires you choose an API Key to use, an HTTP method, and a path. It also optionally takes headers, query parameters, and a body.

One example of this would be when trying to fetch beta testers. I would select my “Personal Team” API Key, “GET” as my HTTP method, and “/betaTesters” as my path. This returns a JSOn response of beta testers that I could list or pass onto other actions for further processing.

There are a lot of examples with “Make Request” that you can use in the “Examples” section of ConnectKit.

![Action Make Request](/images/2020-11-24/action_make_request.jpg)

### Get Apps

This action is a specific implementation of “Make Request”. But instead of returning a JSON response that you would have to parse, this returns an array of “App” objects. I think they are called objects. I actually don’t remember. The cool part though is that you don’t need to manually fetch values by keys like you would with dictionaries or JSON responses. ConnectKit defines an “App” model with specific properties and Shortcuts will show you what properties you can all use when iterating over the results of this action. 

This can take reduce the number of actions from about ten with “Make Request” and manual parsing down to three using “Get Apps”. That is a lot considering most of my Shortcuts involve multiple requests. 

There will be a lot more actions coming in future version of ConnectKit that are like “Get Apps”. Expect actions like “Get Beta Testers”, “Get Beta Groups”, “Get App Versions”, and “Get Builds”. 

![Action Make Request](/images/2020-11-24/action_get_apps.jpg)

### Get Finance Reports and Get Sales Reports

These are actions are some of the most fun! Finance and sales reports aren’t like the other App Store Connect API endpoints. These actions require some specific query parameters and also return a g-zipped .tsv (tab separated values) file. The .tsv is not very easy to parse with iOS’s default actions 🙃 ConnectKit _does_ make this easy for you though! 

The “Get Finance Reports” and “Get Sales Reports” actions provide easy configuration through parameters and then output the reports as an array of dictionaries. I wanted to output models (similar to “Get Apps”) to make using the result easier but the finance and sales reports are very dynamic in their response depending on the type of report you want that it didn’t make sense to modelize them yet. I’m hoping to find a better way to do this in the future!

However, it is still not terrible to use these results 😁 It just requires a little bit of work iterating over the results and pulling values out of a dictionary. There are examples of this you can download and run yourself from within the “Examples” section of the app!

![Action Make Request](/images/2020-11-24/action_get_sales.jpg)

<hr/>

## _What have you (Josh) done with ConnectKit?_

Oh my goodness, that’s another solid question! Everything I have talked about so far feels very meta. I’ve explained what ConnectKit is and the building blocks it offers but not the concrete value that it can provide. And honestly, I think that is probably going to be the hardest part of marketing this app 🤷‍♂️ ConnectKit doesn’t really give the user anything for free. It’s more like puzzle where the user will need to put together the pieces on their own to see the final result.

My quick solution to this puzzle is to offer an “Examples” section in the app. The “Examples” section is an ever growing list of Shortcuts that I’ve made (or other users have made) that can be added into your own Shortcuts. I’m hoping these example Shortcuts can give some inspiration and confidence in users to build and share their own Shortcuts that they find useful!

Anyway... I have made so many Shortcuts already but I know I haven’t even scratched the surface of what is all possible, useful, and fun. I have Shortcuts that I manually run, Shortcuts that I run with Siri, and Shortcuts that run on an automation to update Widgets.
 
See a few of my examples below that showcase what ConnectKit is capable of But be sure to checkout the “Examples” section of the app for even more!

### Add TestFlight User

This is not a Shortcut that I thought would be one of my favorites but... it is 🙂 It was also a really fun one to make! This Shortcut allows for adding a beta user to a TestFlight group. It takes an email address and then presents a list of which group to add the user to. The fun part comes is they are three ways to input that email address.

1. Manually enter email
2. Select from list of contacts
3. From share menu in Contacts app

This Shortcut will get cleaned up in the future when I get around to adding more actions that are specific for beta testers.

<video width="100%" controls>
  <source src="/images/2020-11-24/send_testflight.MOV" type="video/mp4">
Your browser does not support the video tag.
</video>

### Submit App For Review

This one is probably is not useful for most workflows but it was a fun “proof of concept” Shortcut. This Shortcut submits a version of your app for review. It doesn’t prompt for a build list, select latest build, or allow for entering of a change log but it _could_ in the future!

I actually used this action to submit ConnectKit to the App Store for review... with Siri... over CarPlay 😈 Here is video of me using it! 

<video width="100%" controls>
  <source src="/images/2020-11-24/carplay.MOV" type="video/mp4">
Your browser does not support the video tag.
</video>

### Display Sales Reports Charty

ConnectKit would have been a decently useful app on its own before iOS 14 but iOS 14 _really_ makes ConnectKit shine with widgets. Widgets, as most of us know, display data on the home screen. They are are great for seeing information at a glance... especially information that is tedious to get.

[Charty](https://chartyios.app) is one of my favorite widget apps. It allows users to create charts through Shortchuts and either output an image or display the chart as a widget.

In this example I took the daily and months sales report data from the “Get Sales Reports” action and piped it into Charty actions. I run this Shortcut once a day with automations so that my home screen has the latest sales information right on it 😎

![Charty](/images/2020-11-24/charty.PNG)

### Display Metadata In WidgetPack

This example is really similar to the Charty example! [WidgetPack](https://widgetpack.app) is an app that allows for configuring custom widgets through Shortcuts! 

I’ve made multiple Shortcuts for this one that also run on daily automations. I have widgets that show my app review status and total number of TestFlight testers in a group that has a public link.

There are so many other metadata widgets that you could make but these were the two that were ideal for me 😝

![Charty](/images/2020-11-24/widgetpack.PNG)

## ConnectKit's Future and Beyond

I have no plan's to slow down on ConnectKit's feature set now that it got approved 😊 I held off on adding new actions similar to "Get Apps" while it was waiting for review but I'm starting back up on those actions now. I plan to add actions like "Get Beta Testers" and "Submit Version" as a few of my first set of additions but I would love to hear any feedback from you all on what you would like to see next! I built. this as a App Store Connect user and developer tool so I want to help you build your Shortcuts and automations.

Feel free to tweet me ([@joshdholtz](https://twitter.com/joshdholtz)) or [@ConnectKitApp](https://twitter.com/connectkitapp) with any feedback, issues, or feature request! Let's celebrate the abilities that Apple gave us with the App Store Connect API 🥳
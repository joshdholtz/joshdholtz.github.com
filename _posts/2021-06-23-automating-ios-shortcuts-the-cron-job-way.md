---
title: "Automating iOS Shortcuts - The Cron Job Way"
layout: post
date: 2021-06-23 7:30:00
image: /images/2021-06-23/header.png
headerImage: true
tags:
- shortcuts
category: blog
author: joshdholtz
description: iOS app for cropping photos to the shape of emojis
---

Hello, it's me! Josh Holtz. And I do a lot of things that are fun but unnecessary. Today's unnecessary and over-engineered thing is automating iOS (and macOS) Shortcuts using the same syntax that's used to schedule cron jobs 😊

This whole blog post is centered around my "Cron" Shortcut which you can [download here](https://www.icloud.com/shortcuts/f75b29e186aa43c59ab0a9ce981c4f6a). It takes text formatted like 👇

```
0 10 * * * Daily Morning Shortcut
0 9 * * 1 Weekly Monday Shortcut
0,30 * * * * Shortcut Every Half Hour
```

But I recommend you continue reading on 😉

## The Problem

Today's thing was driven by some iOS Shortcuts that I needed to have automated. The three Shortcuts were:

1. Fetch and [alert me of the App Store Connect API version](https://twitter.com/joshdholtz/status/1400935805116428298?s=20) every hour (I'm waiting for a big and important update)
2. Tweet the latest [Indie Dev Monday](https://indiedevmonday.com) article every Monday at 9 am 
3. Tweet the number of days since I [last started a new Xcode project](https://twitter.com/joshxcodeproj) every day at 11 am

<hr/>

## Doesn't Shortcuts Already Have Automations?

Yes. Yes, it does.

Automating iOS Shortcuts (and soon-to-be macOS Shortcuts in Monterey) to run at a certain time is easy to do. You can configure a Shortcut to run daily, on a specific day of the week, or a specific day of the month. See screenshot below 👇

<img src="/images/2021-06-23/1_schedule_automation.png" alt="" data-lity />

After setting the schedule, you then need to build your Shortcut but chaining actions together (similar to how you build non-automated Shortcuts). See screenshot below 👇

<img src="/images/2021-06-23/2_build_automation.png" alt="" data-lity />
 
But it gets tedious if you want to run the same Shortcut multiple times throughout the day. You can’t just reuse the same configuration. You, instead, need to create additional automations.

To get around building the same Shortcut over and over again in each automation, I start off building all my automated Shortcuts as normal, non-automated Shortcuts. This has two benefits.

1. I can test the Shortcut at any time (not just at the scheduled time)
2. I can run and reuse this Shortcut in automations with the “Run Shortcut” action

This approach made it easier to manage and test the Shortcut’s behavior but my automations section started getting out of hand. And once you have a lot of automations, it gets very difficult to see them all and find the correct automation to view or update. There were so many “Run Shortcut” actions but I didn’t know what was being run. This was a side effect of my reuse method from earlier. See screenshot below 👇

<img src="/images/2021-06-23/3_list_of_automations.png" alt="" data-lity />

I now needed a solution to make both viewing and scheduling new jobs easier and more flexible...

And all the signs pointed to something similar to cron jobs 🤷‍♂️

<hr/>

## How Do Cron Jobs Get Scheduled

I’ve been using Unix-like operating systems for the past 17 years for both personal and work. I would often want to automate scripts to run at a certain time (but I don’t remember what specifically for anymore). To do so, I would schedule cron jobs. These jobs are driven by a crontab (cron table). See example below 👇 

```
1 0 * * * printf "" > /var/log/apache/error_log
45 23 * * 6 /home/oracle/scripts/export_dump.sh
```

The format of this is defined by 👇

```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
# │ │ │ │ │                                   7 is also Sunday on some systems)
# │ │ │ │ │
# │ │ │ │ │
# * * * * * <command to execute>
```

This is the perfect user interface for automating jobs. It's been used since the beginning of time in Unix and I wanted to use it for Shortcuts. I'd easily be able to see all of my scheduled Shortcuts on one screen. It would also be very painless to edit the schedule times or add and remove Shortcuts from the list. Pretty user interfaces are nice and what I would expect from Apple but that's not what I needed. Most people probably don’t want to use their mobile device as a driver for many time-based automations. I, however, do 🙃 

So even though Apple doesn’t give me crontab capabilities for scheduling natively in Shortcuts, I decided I would try to build it myself 💪 

<hr/>

## Architecting the Cron Job Shortcuts

Instead of using crontab to run a script (like it would on a Unix-like system), I decided to use the crontab syntax to run a Shortcut by name. This is all made possible by the “Run Shortcut” action I talked about earlier. There are two things needed around the crontab to make Shortcuts behave like cron jobs. 

1. A system to parse `crontab` and execute Shortcuts by name
2. A system to regularly run the parsing and execution

The overall flow looks like this 👇

<img src="/images/2021-06-23/9_flow.jpeg" alt="" data-lity />

### Creating the `crontab` Shortcut

The system to regularly run the parsing and execution of Shortcuts is going to be driven by Shortcut automations. Previously, I have been defining the specific Shortcut I wanted to run at each time in automations. Instead of doing that, this cron job approach will run the same Shortcut every hour and half hour. The Shortcut will run a new Shortcut named `crontab`. See screenshot below 👇

<img src="/images/2021-06-23/4_crontab.png" alt="" data-lity />

Even though real Unix-like cron jobs can be run at any minute, running the `crontab` Shortcut every hour and half hour gave me enough power and flexibility to cover all of my needs. The `crontab` Shortcut itself is simple. There is a text action that holds the crontab syntax (as mentioned earlier). This text is passed to another action called `cron`. See screenshot below 👇

<img src="/images/2021-06-23/7_cron_combined.png" alt="" data-lity />

☝️ This is the exact Shortcut automation configuration that I have scheduled on every hour and every half hour. It's as simple as it can get and doesn't ever need to be changed.

In this example, **“Fetch App Store Connect Version”** is run every single hour. **“Jobs - New Xcode Project”** is run every day at 11 am. **“Indie Dev Monday - Tweet”** is run only Monday at 10 am.

And that’s it 😉 I mean, that’s not it because the `cron` Shortcut is complex. I'll explain that next 😊 

ANYWAY… Adjusting the time I want my Shortcuts to run is now really easy! Let’s say I rename **“Indie Dev Monday”** to **“Indie Dev Monday, Wednesday, and Friday”**. And let's say I wanted to change "Fetch App Store Connect Version" to run from every hour to every half hour.  All I have to do is change my crontab from…

```
0 * * * * Fetch App Store Connect Version
0 11 * * * Job - New Xcode Project
* 10 * * 1 Indie Dev Monday - Tweet
```

to…

```
0,30 * * * * Fetch App Store Connect Version
0 11 * * * Job - New Xcode Project
* 10 * * 1,3,5 Indie Dev Monday - Tweet
```

This took all of about 10 seconds 🙌 Adding new automations to run every half would would have required me to make 24 brand new Shortcut automations without the cron job approach 😝

### Creating the `cron` Shortcut

This is a beast of a Shortcut. It has almost 200 actions that do text parsing, date math, validation 🤯  There is a screen recording of the actions in the Shortcut below but I will list out the high level steps below since that's easier to process 😉 

Download "Cron" Shortcut 👉 [Click here](https://www.icloud.com/shortcuts/f75b29e186aa43c59ab0a9ce981c4f6a)

1. Accepts text input in crontab syntax
2. Reads crontab line by line and maps to list of dictionaries (easier to look up in further processing)
	3. Splits line by spaces
	4. Maps specific index to a variable (0 is the minute, 1 is the hour, etc)
	5. Verifies Shortcut name exists and errors if it doesn’t
	5. Takes these variables and saves a dictionary
	6. Appends dictionary to list  
4. Iterate over crontab list of dictionaries to determine which need to be run
	5. Checks if the day of the week passes
		6. Passes if an exact match or wildcard (*)
	6. Checks if a month passes
		7. Passes if an exact match or wildcard (*)
	7. Checks if the day of the month passes
		8. Passes if an exact match or wildcard (*)
	8. Checks if an hour passes
		9. Passes if an exact match or wildcard (*)
	9. Checks if a minute passes
		10. Passes if an exact match or wildcard (*)
	11. If all passed, appends to list of Shortcuts to run
12. Iterate over Shortcuts to run list and run Shortcuts
	13. Call “Run Shortcut” with the name of Shortcut

And that's it! That’s the `cron` Shortcut that does all the heavy lifting 😊 As seen above, it's broken down into three main parts. The first is mapping the crontab text to a list of dictionaries. The second is taking the full list of Shortcuts and filtering it down to only the Shortcuts that needed to be run at this exact time. The third is executing the Shortcuts.

This was split up this way for a few reasons:
1. Easier to develop and debug the separate parts if something goes wrong
2. Shortcuts can sometimes take minutes to run which would ruin the date math 🤷‍♂️ Moving all the parsing and checking upfront allows the Shortcuts to take however long they need to

I lied, here is a video of the Shortcut if you want to watch it 😉

<video width="100%" poster="/images/2021-06-23/8_cron_shortcut.png" controls>
  <source src="/images/2021-06-23/8_cron_shortcut.mp4" type="video/mp4">
Your browser does not support the video tag.
</video>

### The Negatives

There are sooooooooo many negatives with this approach 😅

#### 1. Large initial setup of automations running every hour and every half hour

That is 48 automations for my setup! But yours may not need this. Maybe you only care about every hour or only the hours you are awake. You don’t need to set up all the automations for every hour if you aren’t going to use them. I just did because I could

#### 2. Notifications on every run of the `crontab` automation

Automated Shortcuts will always send you a notification when they are going to be run. It’s nice to know that your automation is going to run but this means I get 48 notifications that say something like “At 8:00 pm, daily - Running your automation” 😛 It’s not useful and some people may find it annoying but I’m fine with it! 

#### 3. Shortcuts run sequentially and will stop if one fails

There are some times during the day or week that I will have multiple Shortcuts being run at the same hour. There is no way to kickoff multiple Shortcuts at one time so the Shortcuts need to run sequentially. Sequential is not necessarily bad. It does mean it will take a longer time for all the Shortcuts to finish because they can only run one at a time. The bad comes in if one of them fails. If a Shortcut errors while being executed from “Run Shortcuts”, the whole Shortcut stops. This means any other Shortcut that was supposed to run won’t get run 😔 

This isn’t a problem for me since I’ve designed my automated Shortcut in a way where this shouldn’t happen. But it still might 🤷‍♂️

#### 4. Approving Shortcuts to run Shortcuts

I don’t remember if this was added in iOS 14.6 or iOS 15 (Beta) but there are a lot of permission prompts that you will need to accept for your automations to be fully autonomous (that sounds weird 😬). The first time a Shortcut runs a Shortcut with the “Run Shortcut” action, Shortcuts will prompt you for your approval. This is a safety measure of some sort (which I think I approve of) but it does require some user interaction from you the first time.

## The End

I do use this every day but this isn’t meant to be the most stable or efficient Shortcut. This is mainly just a fun experiment for me 😇 I wanted to make it easier for me to view and edit my automated Shortcuts while also testing my Shortcut making abilities. I’d say that I succeeded in both of those things ✅

I also wanted another thing to blog about 😉 

Feel free to tweet me ([@joshdholtz](https://twitter.com/joshdholtz)) or email me if you have any feedback or questions about this. Thanks for reading and happy Shortcutting!

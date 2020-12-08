---
title: "Building a Healthy Living Log with Scriptable"
layout: post
date: 2020-12-08 7:30:00
category: blog
author: joshdholtz
description: I built a Healthy Living Log with Scriptable to track when I exercise and stretch
---

# Healthy Living Log with Scriptable

A few weeks ago I tweeted about a healthy living widget and Shortcuts I put together with Scriptable. I got a quite a few messages asking how I made it so... here it is!

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Just finished writing a baller widget and a bunch of shortcuts with <a href="https://twitter.com/scriptableapp?ref_src=twsrc%5Etfw">@scriptableapp</a> 👇<br><br>✅ Shortcuts to log when I exercise/stretch<br>✅ Persist data in iCloud<br>✅ Show in widget<br>✅ Auto text my friends at 10am if I exercised/stretched the previous day<br><br>Will probs blog about this 😎 <a href="https://t.co/ZCk5rNQCFc">pic.twitter.com/ZCk5rNQCFc</a></p>&mdash; Josh "Typo Maker" Holtz 💪🚀 (@joshdholtz) <a href="https://twitter.com/joshdholtz/status/1328913955843166211?ref_src=twsrc%5Etfw">November 18, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<hr/>

## Backstory

I don’t think there has been a more important time to be aware of physical and mental health. I’ve struggled most of this year to find ways of motivating myself, recording my successes, and finding ways to hold myself accountable. This hasn’t been to much of an issue in the past since I was able to leave my house to do fun physical activity but all of my workouts this year have had to be at home. It’s very easy keep sitting on the couch rather than getting up to do a home workout.

I thankfully have an awesome group of coworkers that have formed a goal accountability group with me. The four of us meet every two weeks to talk about how we did with our goals and receive input on how to improve. My goal has been physical and mental health so that improves both my work life and my personal life.

I don’t remember who brought this up in my group but my group members were willing to get daily notifications of my workout status from the day before. Not only would this motivate me and hold me accountable but my group members would also use this to motivate them with their goals. My first attempt at doing this was through todos in Basecamp. We had a Basecamp project for our accountability group so I created a new task for each day for two weeks that I would checkoff when I worked out. This ended up working but I wanted a solution that was easier to use, more visible on my phone, and not tied to our company Basecamp.

One of my group members told me to make an app but I had just recently come across Scriptable. I knew it was possible for me to make something with a script in Scriptable and combine it with some other Shortcuts.

Here is my current implementation... 😊 

## Implementation with Scriptable and Data Jar

I went through **a lot** of different implementations of this. My first version had four scripts and three shortcuts. It worked but I was not happy with it. What I have now is one widget script, one shortcut for logging my health activities, and one shortcut that runs on an automation for sending my activities to my coworkers.

My requirements for this were:
- Persistent data stored in iCloud
	- Dates I’ve exercised and stretched
- Widget built from persistent data
- Automated shortcut for notifying coworkers/friends my statuses from previous day

### Data Storage

That data format I’m storing looks like this:
```
{
	"Exercise": {
		"2020-12-07": "true"
	},
	"Stretching": {
		"2020-12-06": "true",
		"2020-12-07": "true"
	}
}
```

I tried a few different methods for storing my data. I split them into multiple files that were stored in Scriptable iCloud Drive at first. It worked but it forced me to have multiple and more complex scripts for reading and writing that data both of my logging shortcut and my automated shortcut. I really wanted to only use Data Jar but I couldn’t find a way to load Data Jar directly from my widget script. I ended up using a combination of Data Jar and a file stored in Scriptable’s iCloud Drive.

Data Jar is my primary storage. It offers easy to shortcuts, viewing and editing of data in app, and syncing of data over iCloud. Both of my shortcuts fetch and update my data with Data Jar.

The biggest problem I faced with choosing Data Jar was getting this data in a persistent place for Scriptable widgets to use. Scriptable does not have an API for accessing the data in Data Jar. I needed to not only pass the data into my widget somehow but I also needed the widget to store the data in a place where it could access it.

It took me too long to realize that my problem was also my solution 😊 My workflow looks like this:

1. Logging shortcut reads and updates data with Data Jar
2. Passes Data Jar data as a parameter into my widget script
3. Widget script write data to a file in the Scriptable iCloud drive
4. Widget UI is driven off of this file in the Scriptable iCloud drive

### Logging Shortcut

My logging shortcut is really just a series of menus that adds/updates values in a dictionary. That dictionary is then stored in Data Jar and passed as a parameter into the Scriptable Widget.

[Install Shortcut](https://www.icloud.com/shortcuts/0d9a4a543d4b45cb9e6f3a9178a5017f)

⚠ Due to some OS issues, the Scriptable widget needs to be opened in Scriptable to refresh. Widgets are struggling to refresh from Shortcuts.

### Widget Script

Scriptable’s app and API is so so nice but my javascript is not 😛 This script doesn’t feel too magical but there is a lot of weird things that I think I had to do. It might not be weird but I really don’t do javascript very often 🤷‍♂️

- Write data to iCloud Drive (if passed in from Shortcut)
- Reads data from iCloud Drive
- Draws previous week, current week, and next week
	- Looks in exercise and stretching dictionaries for each day
	- Draws salmon circle around day if exercised
	- Draws blue line under day if stretched

⚠ This is **ONLY** designed for the medium widget right now because I made it for me and I’m lazy.

Feel free to suggest any updates/improvements! I’d be happy to incorporate and reshare 😁

<script src="https://gist.github.com/joshdholtz/164a872ec36e10be3d5df3038d6f57da.js"></script>

### Automated Accountability Shortcut

My accountability shortcut reads the values from Data Jar to see if I exercised and stretched the previous day and then send that in a text message to my coworkers.

There isn’t really much to it besides that 😇 You could easily change up the text part to an email or a tweet or whatever works best for you!

[Install Shortcut](https://www.icloud.com/shortcuts/211b17cf211a4eeeb80ccd92fcf038b5)

## Final Thoughts and Future Plans

I’ve been using this for about four weeks now and I’m super happy with the results! The Shortcut is easy to use, the widget is better looking than I thought, and the automated shortcut makes sure my coworkers now even when I failed.

The best part though is I had a really fun time using Scriptable 🙂 I knew Scriptable was something I would enjoy but I was slightly unsure what I could use it for and intimidated at how to start. It turns out... I had no reason to be intimidated. There are plenty of examples that I used when I got stuck at something. The docs are right there in the editor and are very easy to use and search for. There was also plenty of resources on the internet for me to go to for any other questions I’ve had. I ended up finding things on a forum and Reddit that answered some of my questions.

I will definitely be keeping my healthy living log updated going forward. I’ll be trying to make it work for multiple widget sizes and maybe a little bit more dynamic so I can track more things or change up what I’m tracking.

Feel free to tweet me at [@joshdholtz](https://twitter.com/joshdholtz) if you have any questions or suggestions on what I’ve written!

I also want to give a big shoutout to [Simon](https://twitter.com/simonbs) for making both Scriptable and Data Jar ❤ I’m so glad I could use these existing tools so that I didn’t have to start a new Xcode project to solve my problem 😉 
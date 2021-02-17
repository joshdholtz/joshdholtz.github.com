---
title: "How Apple’s Upcoming Two-Step/Two-Factor Enforcement Could Affect Your fastlane Experience"
layout: post
date: 2021-02-15 7:30:00
_image: /images/2020-12-08/widget.png
_headerImage: true
category: blog
author: joshdholtz
description: 
---

## Preface

This blog post is 100% my thoughts and opinions. It does not reflect _fastlane_’s or Google’s thoughts and opinions.

Also, note that this is blog post is not critiquing or complaining about the enforcement of two-step/two-factor. This blog post is only here to help users understand how they could be affected and the options they have.

We good? Let’s get started.

<hr/>

## Introduction

Apple is requiring that all Apple ID accounts that sign in to App Store Connect turn on two-step verification or two-factor authentication this month. This is a good move as it does increase the security for all Apple IDs and apps on the App Store. It will however have some negative effects on accounts that are used for automation. 

This email was sent out by Apple on November 20th, 2020. 

>Starting February 2021, additional authentication will be required for all users to sign in to App Store Connect. This extra layer of security for your Apple ID helps ensure that you’re the only person who can access your account. You can enable two-step verification or two-factor authentication now in the Security section of your Apple ID account or the Apple ID section of Settings on your device. 

Most users won’t be affected by this. Some users will be mildly annoyed by this. But this change will be crippling to a handful of users.

But _which_ group do you fall in?

I’ve had this question come my way numerous times now so let’s answer it once and for all 😊 

<hr/>

## Comparing "two-step verification" vs "two-factor authentication"?

We could go into a lot of detail about the differences between two-step verification (2SV) and two-factor authentication (2FA). There are plenty of blog posts that get more technical but we are going to keep it simple today. Below are how most Apple ID accounts will see two-step verification and two-factor authentication.

### Two-Step Verification (2SV)

Two-step verification is powered by a phone number. After signing in to your Apple ID account, 6 digit verification code is sent via SMS or phone call. This code will need to be entered into the form into the device you are logging into. 

You can also have multiple phone numbers attached to your Apple ID account. This is great if you have a team Apple ID with multiple people that need to sign into it. These phone numbers can be set up on [appleid.apple.com](appleid.apple.com). This was the first additional security factor added to the Apple ID account.

### Two-Factor Authentication (2FA)

Two-factor authentication might be the form most people are familiar with. After signing in to your Apple ID account, this security method shows a popup on your Apple devices (iPhone, iPad, Apple Watch, Mac) that says something like "Apple ID Sign In Requested" with a location and map of where it’s being signed in from. After you click "Allow", a 6 digit code appears. This 6 digit code is what you enter on the device your logging in from.

Apple will always attempt the 2FA method first if it's possible. This security step works great for individual accounts but it less great for Apple IDs that are shared by a team.

Luckily, you can always fall back to 2SV! You will see a button/link that says "Didn’t get a verification code?" that will take you two an option to use a phone number for either SMS or phone call verification.

<hr/>

## So... Will this affect you?

I can’t answer this for you but I can help you answer it 😇  I made a flowchart that should lead you to your answer. This flowchart does not cover every use case but it should hopefully be a good compliment to the questions that are about to follow.

<img src="/images/2021-02-15/flowchart.jpeg" alt="Flowchart for seeing how Apple ID affects you" data-lity />

### Do you already have an Apple ID account with 2SV/2FA enabled?

This new requirement Apple is enforcing this month (February 2021) is for Apple IDs that don’t already have 2SV/2FA enabled. If you already have it then the following reading will just be for your enjoyment 😉 

If you don’t have 2SV/2FA enabled, your life will be changing a little bit. Keep reading to figure out how 👇

I have a few Apple IDs that I manage. My Apple ID has had 2SV/2FA enabled for a long time now. But I’ve also managed several Apple IDs that **did not** have 2SV/2FA enabled. These accounts were used specifically for _fastlane_ automation (locally and on CIs). The passwords were either stored in my local Keychain Access or secure environment variables on the CI. I never had to worry about my automation stalling because these accounts only needed email and a password.

### Do you use Xcode and the App Store Connect website?

You will probably only be affected a little bit when using Xcode and the App Store Connect website to upload and release your apps. 

Xcode allows you to sign in to your Apple ID through the Preferences window. I don’t remember if signing into your Apple ID through Xcode presents a 2SV/2FA dialog but this might be a place where you see the new security flow.

You will also start seeing the 2SV/2FA prompts when signing into App Store Connect ([appstoreconnect.apple.com](appstoreconnect.apple.com)). As mentioned earlier, you will see a new input for 2SV/2FA codes after entering your email and password. I can never pinpoint the exact session length but you should be able to go between 15 and 30 days without needing to use 2SV/2FA again.

### Do you run _fastlane_ locally?

_fastlane_ has historically only offered Apple ID as the only login method when interacting with Apple’s services. There was a recent addition of authenticating with the [App Store Connect API Key](https://docs.fastlane.tools/app-store-connect-api/) but the majority of users that are probably questioning 2SV/2FA have not moved over to that yet.

But... if you are still on Apple ID and only run _fastlane_ locally, you will experience a very minor change. The change won’t even be in your day-to-day work. It will just be a few times a month or so 😊

_fastlane_’s Apple ID login works the same as the web login to App Store Connect website mentioned above. Every 15 to 30 days, _fastlane_ will prompt you for a 2FA code. This will popup that system dialog on your Apple devices. You will simply need to enter that 6 digit code in your CLI. 

_fastlane_ also supports 2SV if you don’t want to use 2FA. Instead of entering in the 6 digit code, type in either "sms" or "phone" and _fastlane_ will fallback to using your phone number as the two-step method.

Besides needing to enter this code whenever the sessions expire every few weeks, you really shouldn’t notice any big changes.

### Do you run _fastlane_ on a CI?

This is where a majority of the heartaches and headaches will come from 🙃 _fastlane_ is built to run as easily on a CI as it is on a local machine. The enforcing of 2SV/2FA, however, will end up taking down most CIs that use _fastlane_ that use Apple ID authentication. That sounds pretty grim... but it is not the end of the world! There are two solutions for this.

The first is to keep using the Apple ID authentication but with a pre-generated session. The second is to migrate from using Apple ID authentication to App Store Connect API Key authentication.

Keep reading to learn which is best for you (and your team).

#### Option 1: Keep using Apple ID but with pre-generated session

Apple requiring 2FA/2SV doesn’t mean that you can’t still use your Apple ID to authenticate on a CI. But it does mean that you will have a little bit more maintenance/upkeep to have a valid Apple ID session on your CI.

You previously may have put your Apple ID email address and password in your CI’s secure environment variables. This won’t work anymore. _fastlane_ will attempt to prompt for a 2FA/2SV code which will either halt or fail your CI process. But how do we get around this? The trick is now to generate a session on your local machine.

Instead of setting your Apple ID email and password which creates a new session on your CI, you will instead set the `FASTLANE_SESSION` variable. So what is this `FASTLANE_SESSION` value? You can think of it as the cookie that your browser stores when you login into App Store Connect and enter your 2FA/2SV code there. That valid session cookie hangs around for some time (15 to 30 days) and so that you don’t need to log in or enter the 2FA/2SV code again.

We can do something similar with _fastlane_! All you need to do is run `fastlane spaceauth` on your local machine. You will need to enter your Apple ID email, password, and 2FA/2SV code. This command will then output the value that you need to use with the `FASTLANE_SESSION` variable. 

It’s more work than you are currently doing but it shouldn’t be a daunting amount of work. The worst part is that you may have to restart your CI job when your existing session expires.

💡 Is it too exhausting navigating the user interfaces of your CI? Well.. your CI might have an API you can use for setting environment variables! You _could_ create a _fastlane_ lane (that you run locally) that generates the `FASTLANE_SESSION` and programmatically updates it on your CI for you 😉 

- [Docs on FASTLANE_SESSION](http://docs.fastlane.tools/best-practices/continuous-integration/#environment-variables-to-set)
- [Docs on pre-generated session](http://docs.fastlane.tools/best-practices/continuous-integration/#spaceauth)

#### Option 2: Migrate to App Store Connect API Key

This is my recommended approach if you can make this work for you as migrating from Apple ID to the App Store Connect API Key _should_ be a minimal change for most users. 

Instead of using the `username` option or `FASTLANE_USER`/`FASTLANE_PASSWORD` environment variables, you would use the `api_key` or `api_key_path` options or the `APP_STORE_CONNECT_API_KEY` or `APP_STORE_CONNECT_API_KEY_PATH` variables 😊 

A majority of the tools/actions have support for these new options/environment variables:
- Tools
  - cert
  - deliver
  - match
  - pilot
  - precheck
  - sigh
- Actions
  - app_store_build_number
  - latest_testflight_build_number
  - register_device
  - register_devices
  - set_changelog

It _should_ be a small code change to make the change over for these tools. I recommend going this route as this uses an official API that is supported and documented by Apple. It’s a more stable path for _fastlane_ to use compared to the Apple ID auth APIs.

- [Docs on App Store Connect API](http://docs.fastlane.tools/app-store-connect-api/)

But... if you use the custom `Spaceship` code, `produce`, `pem`, or `download_dsyms` this may not be the best option for you. These tools cannot be fully supported by the App Store Connect API Key yet. The official APIs for these are not released yet. I don’t know an ETA for these yet but I’m hoping it happens soon 😊 

<hr/>

## Other Changes You Might Need To Make

Keeping your Apple ID auth with `FASTLANE_SESSION` or migrating to the App Store Connect API Key might not be enough for you. 

Maybe there are some tools you use that aren’t available with App Store Connect API? Maybe you want to move your CI away from using Apple ID and App Store Connect API auth altogether?

Below are some situations you may run into and how to possibly fix them. This isn’t the complete list but I’m hoping it will help you think of other possible solutions 😉 

### #1: Rethink `download_dsyms` strategy

Since the announcement of bitcode in Xcode, the `download_dsysm` has been a crucial action to a lot of users. Sending the bitcode to App Store Connect allows Apple to optimize the binaries for a different distribution of the apps. This makes the binaries slightly different and can make crash logs different. Developers need to pull down these new dSYM files from App Store Connect to properly de-symbolicate their crash logs. The `download_dsms` is an action that you would run after the build is done processing to download these dSYM files from App Store Connect with your Apple ID.

But now that Apple ID will have 2FA/2SV, you _may_ need to adjust your _fastlane_ setup.

#### Run locally or in a separate job

In _most_ cases, the dSYM doesn’t _need_ to be downloaded right after a build has finished processing which means that you _might_ not need to run `download_dsyms` on your normal CI job.

This could instead be run on a separate job that runs once a day or a few times a week. Moving it to a separate job will prevent the job from failing if that `FASTLANE_SESSION` expiries.

You could also move this to a job that just gets run locally whenever you start your day 🤷‍♂️

#### Can you disable bitcode? Maybe you don’t need `download_dsyms`

Or maybe... maybe you don’t even need bitcode?! If you disable bitcode, you can use the dSYMs directly from your Xcode build. Now you don’t even need to worry about `download_dsyms` action 🤷‍♂️

https://twitter.com/steipete/status/1360535259905990657?s=21

### #2: Do you even need Apple ID or App Store Connect API Key?

If you aren’t able to make `FASTLANE_SESSION` work for you or if you can’t use the App Store Connect API Key for some reason, you aren’t stuck! You can still set up a CI that signs and uploads binaries with either of those 😏 

If you are making use of `match` with read-only mode for signing, you don’t need to make use of any auth. `gym` also does not need any auth to build and sign your app.

If you are uploading your binary to the App Store or TestFlight, you can use either `deliver` or `pilot` with `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`. This does not require Apple ID or the App Store Connect API Key.

- [Docs on Application Specific Passwords](http://docs.fastlane.tools/best-practices/continuous-integration/#application-specific-passwords)
- [Docs on pilot with Application Specific Password](http://docs.fastlane.tools/actions/pilot/#use-an-application-specific-password-to-upload)

### #3: `produce` and `pem` won’t fully work with App Store Connect API Key

`produce` and `pem` are the last two tools that have not had a big migration over to the new App Store Connect API. The reason being there are currently some App Store Connect APIs missing that makes this possible. Those APIs are:

- Creating push certificates
- Creating apps on App Store (you can create new app identifiers on Developer Portal)

With that being known, `produce` and `pem` will still need to use the Apple ID auth for the time being. If you need to use these in your flow, you will need to make use of `FASTLANE_SESSION` or find a way to split up your jobs.

These tools will be updated as soon as they possibly can when the new APIs become available.

### #4: Do you use a shared Apple ID? Add multiple phone numbers for Two-Step Authentication

I’ve mentioned this above a little bit but I just wanted to call this out again. Some users like to run _fastlane_ locally but with a shared Apple ID that is only used for _fastlane_ related things. These Apple IDs will also be subject to the 2FA/2SV requirement.

If you’d like to still use these not like the 2FA/2SV interrupt your workflow, your best bet here is to set multiple phone numbers on this Apple ID which can be used for 2SV. If the user gets hit with needing to use a 2SV, they would need to select their phone number from the list to get the 6 digit code for verification.

### #5: You might need to migrate custom Spaceship code

A lot of users take automation into their own hands and use `spaceship` to handle Developer Portal and App Store Connect APIs directly. In the past, this has all been done with the `Spaceship::Portal` and `Spaceship::Tunes` modules. These modules access the legacy API which uses an Apple ID.

There is another module that interacts with the App Store Connect API. That module is the `Spaceship::ConnectAPI` module.   This module takes both either Apple ID auth or App Store Connect API Key auth. The Apple ID auth hits the same private API that the websites use. The API Key auth hits the official API.

If you are running into issues using custom `spaceship` with Apple ID and 2FA/2SV, you may need to look into migrating your code over to API Key auth with `Spaceship::ConnectAPI`

- [Docs for Spaceship’s App Store Connect](https://github.com/fastlane/fastlane/blob/master/spaceship/docs/AppStoreConnect.md)

<hr/>

## If you REALLY need Two-Step Authentication on CI... there _are_ ways 😈

If you _really_ need to keep using Apple ID, there _are_ ways to programmatically enter your 2FA code. Below is a monkey patch to overwrite the `ask_for_2fa_code` method instead of `spaceship`. This method is what would normally prompt for the code via the CLI but you could use this to get the 2FA code from where ever you want.

```
Spaceship::Client.send(:define_method, :ask_for_2fa_code) do |message|
   some_method_to_get_2fa
end

def some_method_to_get_2fa
  # maybe poll from a message queue
  # maybe poll from a twilio
  # maybe poll from a web form waiting for user input
end
```

### Send 2SV to an Android phone number

I don’t have an Android phone with an active number but this an approach I’ve heard of people doing and that I would like to try. Android allows for the apps to programmatically read SMS messages. With this ability, an Apple 2SV code getting sent to an Android phone can get forward into the _fastlane_ job. This could get forwarded into a message queue that the monkey patch polls for.

There are more than enough ways for this to work but this is one suggested way if you need to keep using your Apple ID in an automated way.

⚠️ I do want to call out that you please assess any potential security issues involved when trying this approach.

## That’s All Folks

I mean... I don’t think there is ever an end to different _fastlane_ approaches we can talk about when it comes to mitigating effects from the enforcing of 2FA/2SV. But I think that is all that I can fit into this blog post.

As a reminder, this blog post was not for analyzing or criticizing Apple’s enforcement of 2FA/2SV. It is not my job to judge this and nor should it be. This blog post was simply to inform _fastlane_ users what Two-Factor Authentication and Two-Step Verification mean and different approaches to address issues they may run into when the 2FA/2SV enforcement comes into play.

If you see any issues in this article or have any feedback, please feel free to tweet me at [@joshdholtz](https://twitter.com/joshdholtz) or email me.

It’s been a pleasure having your attention to the very bottom of this article ❤️ Happy _fastlaning_!

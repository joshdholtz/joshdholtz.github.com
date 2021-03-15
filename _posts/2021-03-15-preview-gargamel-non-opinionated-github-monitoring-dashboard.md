---
title: "Preview: Gargmel - A non-opinionated GitHub monitoring dashboard powered by YAML"
layout: post
date: 2021-03-15 7:30:00
image: /images/2021-03-15/1-fastlane.png
headerImage: true
category: blog
author: joshdholtz
description: 
---

I told myself I wasn’t going to work on other side projects.. I did not want to stretch myself to thin while being a new dad, lead maintainer of _[fastlane](https://fastlane.tools)_, and just recently release [An Otter RSS](https://anotterrss.com) and [ConnectKit](https://connectkit.app). But, while focusing on my day-to-day _fastlane_ work, I shortly realized there was another tool that I needed that didn’t exist.

_fastlane_ has one main repository under the   [https://github.com/fastlane/fastlane](https://github.com/fastlane/fastlane) organization... but that is not the only one. There are about four other repositories that I need to monitor regularly. There is also the [https://github.com/fastlane-community](https://github.com/fastlane-community) organization which contains _fastlane_ plugins and dependencies that _fastlane_ users rely on that needed a new home 😇 There are a total of 19 repositories in there that need some monitoring. Most of these repositories aren’t _super_ active but are still active.

I have GitHub notifications enabled for repositories but it’s very, _very_ easy to let important notifications slip by. I needed a tool that helps me monitor the health of these repositories while also giving my GitHub notifications a supercharged filter to show me notifications that I might have missed.

And that tool is “Gargamel” 😈

<hr/>

## Gargamel 

Gargamel is a non-opinionated monitoring dashboard powered by a YAML file. It was meant to work only with the GitHub API but actually can work with any API.

That probably doesn’t mean much so keep reading about the requirements, the development decisions, and the product 😉 

### The Requirements

Gargamel is 100% intended to an app for 100% me 😊 Going into this I did not take anybody’s needs except myself into this. I needed a tool that fit my very specific needs. With that in mind, the first thing I did was put together some quick notes on what I needed to make. But the important part wasn’t what I needed to make... it was also what I **didn’t need** to make. I wanted to make sure I boxed my expectations into something that didn’t get out of hand 😇 I didn’t want to start polishing the app and making it super performant from the beginning. I wanted something that took me a few partial days of hacking that “just worked”.

<hr/>

```md
## Description
Dashboard to monitor GitHub repositories and associated notifications. Also allows a custom calculated health or warning system when attention is needed.

## MVP
- YAML configuration file
- Repo view
    - Org/name
    - Custom field and value
        - https://stackoverflow.com/a/21233623
- Notification view
    - Group notifications by repo
    - Filter notifications (better than GitHub)
        - Allow batch clearing of notifications
        - Eample
            - Things fastlane bot closed
            - PR status changes
            - PR notifications
            - Issue notifications
            - Discussion notifications

## Things to not care about
- Speed and caching
    - This will not be looked at often (maybe only at start, middle, and end of day)
- Background refresh
    - Might be a long running job because of number of repos and configurations
    - Could run in background but not necessary (especially on iOS)
- Don't make pretty
    - Just work
```

<hr/>

### The Development Decisions

Based upon these requirements I set for myself, I decided Gargamel would:

- Be a SwiftUI app (for macOS and iOS)
	- Rapid development
- Don’t use persistent storage (Core Data)
	- Mapping responses is too much effort for what I wanted
	- Cache will almost always be invalidated
		- Data changes frequently 
		- I will only refresh maybe a few times a day 
	- Use `URLCache`  with `URLSession` 
		- GitHub API supports ETags
		- Will prevent unnecessary data transfer (quicker response times) if no changes
- Use YAML for configuration
	- No UI needed besides SwiftUI’s TextEditor
	- Very flexible if I run into roadblocks and need to pivot
  - YAML has "anchors" which can be used to reuse basic auth and code definitions
- Run data filtering and view configuration in JavaScriptCore
	- I did not want to hardcode any logic in Swift
	- Each type of view was going to be configured very differently
	- API responses will get fed into a function fun in JavaScript Core
		- Can optionally filter data
		- Return a JavaScript object that configures the few

#### YAML Configuration

1. YAML drives the views (either a grid or list type)
2. Views have API endpoints that will get requested
3. Views get defined with code sections that will be executed using JavaScriptCore
4. API responses get forwarded and executed in JavaScriptCore
5. SwiftUI renders data return from JavaScriptCore

Here is a simple sample that displays `fastlane/fastlane` and `fastlane/docs` in a grid view:

```yaml
aliases:
  personal_token: &personal_token
    username: "YOUR_GITHUB_USERNAME"
    password: "YOUR_GITHUB_PERSONAL_ACCESS_TOKEN"
  repo_health: &repo_health |
      function(repo, issues, pulls) {
        // Need to filter out pull requests
        issues = issues.filter(function(issue) {
          return !issue.pull_request;
        })

        return {
          “fields”: [
            {
              “name”: “Open Issues”,
              “name_weight”: “bold”,
              “value”: issues.length
            },
            {
              “name”: “Open Pulls”,
              “name_weight”: “bold”,
              “value”: pulls.length
            }
          ]
        };
      }
views:
  -
    name: 👀 fastlane
    type: grid
    items:
      - 
        title: fastlane/fastlane
        subtitle: 
        endpoints:
          -
            endpoint: https://api.github.com/repos/fastlane/fastlane
            basic_auth: *personal_token
          -
            endpoint: https://api.github.com/repos/fastlane/fastlane/issues?state=open&per_page=100
            basic_auth: *personal_token
            all: true
          -
            endpoint: https://api.github.com/repos/fastlane/fastlane/pulls?state=open&per_page=100
            basic_auth: *personal_token
            all: true
        code: *repo_health
      - 
        title: fastlane/docs
        subtitle: 
        endpoints:
          -
            endpoint: https://api.github.com/repos/fastlane/docs
            basic_auth: *personal_token
          -
            endpoint: https://api.github.com/repos/fastlane/docs/issues?state=open&per_page=100
            basic_auth: *personal_token
            all: true
          -
            endpoint: https://api.github.com/repos/fastlane/docs/pulls?state=open&per_page=100
            basic_auth: *personal_token
            all: true
        code: *repo_health
```

<hr/>

### The Product

I’m very happy with what I’ve thrown together with fairly minimal work 😊 

I have...

- 2 grid views for the `fastlane` and `Fastlane-community` organizations
	- Every repo monitors
		- Number of open issues
		- Number of open PRs
		- Last release
	- Main `fastlane/fastlane` repository also monitors
		- Number of issues since last release
		- Number of open regressions
		- Number of open regressions since last release
- 5 list views
	- List `fastlane/fastlane` regression issues
	- List `fastlane/fastlane` issues with a lot of reactions
	- List `fastlane/fastlane` notifications that are only PRs
	- List `fastlane/fastlane` notifications that are only issues
	- List `fastlane/fastlane` notifications that are only discussions

The grid views are what I was really after when making Gargamel.  It's not super pretty but it allows me to easily see the health of all of _fastlane_'s parts 😎

The notifications lists aren't very interactive at the moment and I'm not sure if I will implement anything for them in the future. This is mainly to get my attention to attend to these issues somewhere else. 🤷‍♂️

_Side note: I'm currently testing out [Lotus](https://getlotus.app) for managing GitHub notifications_

#### My YAML Configuration

There is **a lot** to this YAML file 😬 A lot of it is copy-paste and I may work on finding ways to trim this down in the future but... I don't expect this to change too often. This file can easily be edited in a text editor (which I don't want to recreate).

<style type="text/css">
  .gist {width:500px !important;}
  .gist-file
  .gist-data {max-height: 500px}
</style>
<script src="https://gist.github.com/joshdholtz/c0dbfd1510ee17bf221b0a3704ff05ff.js"></script>

#### Screenshots

These are screenshots that match the YAML configuration above 👆 

##### fastlane
<img src="/images/2021-03-15/1-fastlane.png" alt="" data-lity />

##### fastlane-community
<img src="/images/2021-03-15/2-fastlane-community.png" alt="" data-lity />

##### fastlane regressions
<img src="/images/2021-03-15/3-fastlane-regressions.png" alt="" data-lity />

##### fastlane big reactions
<img src="/images/2021-03-15/4-fastlane-big-reactions.png" alt="" data-lity />

##### Notifications - fastlane pull requests
<img src="/images/2021-03-15/5-notification-prs.png" alt="" data-lity />

##### Notificatinos - fastlane issues
<img src="/images/2021-03-15/6-notifications-issues.png" alt="" data-lity />

##### Notifications - fastlane discussions
<img src="/images/2021-03-15/7-notifications-discussions.png" alt="" data-lity />

### The Future

I'm not _exactly_ sure where I'm going to take Gargamel in the future. I made this for me but I also wanted to share it because I love it 😊 I don't _really_ want to productize it. That's a lot of added pressure and I'm not sure I could make everybody happy. I'm thinking of open sourcing it if other find that this would be useful. I don't want to recruit anybody to help because that is added pressure but I'd be happy if others found excitement in this.

If you see any issues in this article, have any feedback, or would have interest in contributing to Gargamel, please feel free to tweet me at [@joshdholtz](https://twitter.com/joshdholtz) or email me.

Happy side projecting, everyone! 😜
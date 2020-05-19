---
title: Release Announcement - fastlane plugin for setting up GitHub Actions
layout: post
date: 2020-05-19 7:30:00
image: /images/2020-05-19/github_action_output.jpeg
headerImage: true
tags:
- fastlane
- ci
- github
category: blog
author: joshdholtz
description: A new fastlane plugin for setting up GitHub Actions for running fastlane
---

View project on GitHub 👉 [fastlane-plugin-github_action](https://github.com/joshdholtz/fastlane-plugin-github_action)

## Preface

As a long time user, consultant, and maintainer of _fastlane_, I’ve setup a lot of continuous integration (CI) servers over the years. I’ve used most of the major CI services (like CircleCI, TravisCI, and Bitrise) and they all have two things in common -- a lot of website clicking and a YAML file for configuration.

Over the past few weeks I've been tasked with migrating and setting up new projects on GitHub Actions. GitHub Actions is one of the newer CIs out there. Unlike most CIs, GitHub Actions isn’t the core product. Its a nicely integrated addition into repositories already hosted on GitHub.

The developer experience around GitHub Actions is very well done. Its feels seamless with the rest of GitHub’s interface. The setup process, however, felt similar to other CIs when configuring for _fastlane_. It requires a manual configuration for setting up SSH keys, a tedius secrets and environment variable input, and handwriting of a YAML file.

### The setup

Setting up _[match](https://docs.fastlane.tools)_ to work with _[match](https://docs.fastlane.tools/actions/match)_ requires two repositories. One repository is the project repository. This is the repository that contains our iOS, macOS, or Android project. The second repository is our _match_ repository. Its a repository that stores encrypted copies of Apple certificates and provisioning profiles used for signing.

The GitHub Action on our project repository does not have access to other repositories outside of itself. An SSH key (called a[Deploy Key](https://developer.github.com/v3/guides/managing-deploy-keys/) on GitHub) needs to be used to authorize a connection for our GitHub Action to clone our _match_ repository.

After that, the private key part of the Deploy Key needs to be stored in our project [repository secrets](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets). This will be used later when writing the Workflow YAML configuration that powers our GitHub Action.

CI jobs that build and deploy native apps require secrets -- and sometimes a lot of them 😉 The values of these secrets shouldn’t be committed to the repository and therefore need to be entered into the service somewhere. Unlike other CIs which have a single step for using secrets in a job, GitHub Actions requires two steps. Firstly, all of your secrets need to be added to your repository through a web interface. Secondly, all of your secrets need to be set to environment variables in your Workflow YAML configuration. Most other CIs will inject the secrets as environment variables for you automatically.

Now that all of that is done we are finally ready to create the Workflow YAML!

Every Workflow configuration needs to start with how the GitHub Action will be triggered. I usually start off with something basic like the following:
 
```yaml
on:
  pull_request:
    branches:
      - master
```

Secrets need to be manually set to load into environment variables in GitHub Actions. Below is a sample of what that would look like:

```yaml
        env:
          HOCKEY_API_TOKEN: ${{ secrets.HOCKEY_API_TOKEN  }}
          FIREBASE_APP_ID: ${{ secrets.FIREBASE_APP_ID  }}
          MATCH_DEPLOY_KEY: ${{ secrets.MATCH_DEPLOY_KEY  }}
          GIT_SSH_COMMAND: "ssh -o StrictHostKeyChecking=no"
```

The private key part of our Deploy Key needs to be added to the GitHub Action for _match_ to be cloned from within our _fastlane_ execution. The following commands will do that:

```
        run: |
          eval "$(ssh-agent -s)"
          ssh-add - <<< "${MATCH_DEPLOY_KEY}"
          bundle exec fastlane test
```

<hr/>

I’m exhausted now 😪 That was only one project with a very simple setup.

I’m a lazy developer. I don’t want to configure CI by clicking through websites. I didn’t want to copy and paste YAML files between projects I’ve already setup.

I wanted a proven and repeatable process for setting up _fastlane_ configured with _match_ on a GitHub Actions.

So...

## Happy release day!

Happy official release day to my latest _fastlane_ plugin, `github_action` 🥳

This GitHub Action setup and configuration that we’ve gone through above can all be done with one command in CLI or calling one action in your `Fastfile`.

### CLI

```sh
bundle exec fastlane run github_action \
  api_token:"your-github-personal-access-token-with-all-repo-permissions" \
  org:"your-org" \
  repo:"your-repo" \
  match_org:"your-match-repo-org" \
  match_repo:"your-match-repo" \
  dotenv_paths:"fastlane/.env.secret,fastlane/.env.secret2"
```

### Fastfile

```ruby
lane :init_ci do
  github_action(
    api_token: "your-github-personal-access-token-with-all-repo-permissions",
    org: "your-org",
    repo: "your-repo",
    match_org: "your-match-repo-org", # optional
    match_repo: "your-match-repo", # optional
    dotenv_paths: ["fastlane/.env.secret", "fastlane/.env.secret2"] # optional
  )
end
```


### What does `github_action` all do?

Great question! It automates the steps of creating an SSH key for your Deploy Key, sets your secrets, and generates a working Workflow YAML file 💪

Below are the those steps in more detail:

#### 1. Prompts you if `setup_ci` is not found in your `Fastfile`
Running _fastlane_ on a CI requires the environment to be setup properly. Calling the [setup_ci](http://docs.fastlane.tools/actions/setup_ci/#setup_ci) action does that by configuring a new keychain that will be used for code signing with _match_

#### 2. Create a Deploy Key on your _match_ repository to be used from your GitHub Action
A [Deploy Key](https://developer.github.com/v3/guides/managing-deploy-keys/) is needed for GitHub Actions to access your _match_ repository. This action creates a new SSH key and uses the public key for the Deploy Key on your _match_ repository.

This will only get executed if the `match_org` and `match_repo` options are specified.

#### 3. Set the Deploy Key private key in secrets (along with secrets in your [dotenv](https://github.com/bkeepers/dotenv) file(s)
The private key created for the Deploy Key is store encrypted in your [repository secrets](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets). The private key is stored under the name `MATCH_DEPLOY_KEY`. 

Encrypted secrets will also get set for environment variables from [dotenv](https://github.com/bkeepers/dotenv) files specified by the `dotenv_paths` option.

#### 4. Generate a Workflow YAML file to use
A Workflow YAML file is created at `.github/workflows/fastlane.yml`. This will enable your repository to start running GitHub Actions right away - once committed and pushed :wink:. The Workflow YAML template will add the Deploy Key private key into the GitHub Action by loading it from the `MATCH_DEPLOY_KEY` secret and executing `ssh-add`. All of your other encrypted secrets will also be loaded into environment variables for you as well. 

```
name: Execute fastlane

on:
  pull_request:
    branches:
      - master

jobs:
  build_dev:
    name: Execute fastlane
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@master
      - name: Install Ruby Dependencies
        run: bundle install

      - name: Match Repo Clone Test (please delete this)
        env:
          GIT_SSH_COMMAND: "ssh -o StrictHostKeyChecking=no"
          MATCH_DEPLOY_KEY: ${{ secrets.MATCH_DEPLOY_KEY }}
        run: |
          eval "$(ssh-agent -s)"
          ssh-add - <<< "${MATCH_DEPLOY_KEY}"
          git clone git@github.com:joshdholtz/match-repo-for-fastlane-plugin-github_action.git
          ls match-repo-for-fastlane-plugin-github_action

      - name: fastlane
        env:
          APPLICATION_SPECIFIC_PASSWORD: ${{ secrets.APPLICATION_SPECIFIC_PASSWORD  }}
          HOCKEY_API_TOKEN: ${{ secrets.HOCKEY_API_TOKEN  }}
          FIREBASE_APP_ID: ${{ secrets.FIREBASE_APP_ID  }}
          MATCH_DEPLOY_KEY: ${{ secrets.MATCH_DEPLOY_KEY  }}
          GIT_SSH_COMMAND: "ssh -o StrictHostKeyChecking=no"
          MATCH_READONLY: true
        run: |
          eval "$(ssh-agent -s)"
          ssh-add - <<< "${MATCH_DEPLOY_KEY}"
          bundle exec fastlane test
```

## The final step

After running `github_actions`, the last step is to commit the generated `fastlane.yml` file and push up to GitHub! I will also do this in a pull request so verify that everything is working. You should see GitHub Action output similar to the below image.

![GitHub Action Output Example](/images/2020-05-19/github_action_output.jpeg)

Here is a screen recording of the entire process if you don’t believe me that this works 🙃

<video width="100%" poster="/images/2020-05-19/github_action_screen_recording_poster.jpeg" controls>
  <source src="/images/2020-05-19/github_action_screen_recording.mov" type="video/mp4">
Your browser does not support the video tag.
</video>

## Let’s wrap it up

Thanks for reading! This plugin may not work for everyone‘s workflow but I hope it can still be helpful. Create any issues or pull requests on the plugin if you see anything that needs changing. I’d be happy to build out new features if there is anything that is missing.

View project on GitHub 👉 [fastlane-plugin-github_action](https://github.com/joshdholtz/fastlane-plugin-github_action)

Feel free to message me on Twitter if you have any questions at [@joshdholtz](https://twitter.com/joshdholtz) 😄


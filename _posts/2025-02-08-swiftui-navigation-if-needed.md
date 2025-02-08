---
title: SwiftUI - Navigation If Needed
layout: post
date: 2025-02-08 06:00:00
image: /images/2025-02-08/header.png
headerImage: true
tags:
    - swiftui
category: blog
author: joshdholtz
description: I needed a way to add a toolbar in a view in SwiftUI without knowing if that view came from a navigation stack or not.
---

_Taps microphone_

Is this thing on?

Okay wow, it's been nearly 3 years since I last wrote a blog post. I would normaly say here that I've been meaning to write more blog posts but that would be a lie. I already get myself into too much trouble working on other things 😅

Are you new here? Wondering what those thigns are?

The projects I’ll be working on (but not limited to) are:

-   Co-founder of [Deep Dish Swift](https://deepdishswift.com/)
-   Lead maintainer of [fastlane](https://fastlane.tools/)
-   Engineer Manager of Monetization/Paywalls at [RevenueCat](https://www.revenuecat.com/)
-   Apps I've shipped
    -   [An Otter RSS](https://anotterrss.com/)
    -   [ConnectKit](https://connectkit.app/)
    -   [What's My Age Again](https://apps.apple.com/app/id1608719208)
    -   [Oh Crop!](https://apps.apple.com/app/id1608719208)
    -   [Playpen](https://twitter.com/playpenapp)
-   Other Stuff
    -   [DeckUI](https://github.com/joshdholtz/DeckUI)

But besides _that_, I also have a family that I love to spend time with that takes priority over all of this.

You aren't here for that though... you are here because you want to know the madness behind my **"Navigation If Needed" SwiftUI view**.

👉 BTW, [click here](#the-solution-that-i-ended-up-with) to jump to the solution way way way way way way at the bottom.

## The Problem

Okay, here is the problem I was running into.

I have a view that has a requirement to show a toolbar with some buttons on it. (See example below)

```swift
struct MyViewWithToolbar: View {
    var body: some View {
        VStack {
            Text("This is not a Xib or Storyboard view")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Restore") {
                    // Restore the user's content
                }
            }
        }
    }
}
```

Looking at this view, it _seems_ like the toolbar should be visible. However, a toolbar in SwiftUI will only show if the view is in a `NavigationView` or `NavigationStack` (which makes sense).

If I was making this view for some of my own apps, I'm 100% in control of the presentation logic so I would know whether I needed to wrap this view in a `NavigationView` or not.

However, I am making this view for a SDK and I don't want the user to have to worry about this. I need `MyViewWithToolbar` to know if it should wrap itself in a `NavigationView` or not.

## The Solution (that I wanted)

I wanted a nice, clean built-in solution to this problem. I was looking if SwiftUI had any way to detect if a view was in a navigation stack or not. Long story short, it doesn't.

I scoured the web and asked all the AI chat friends that I've made and I couldn't find any "nice" solutions to this. Some suggested to drop down into UIKit and inspect the view hierarchy. I didn't want to do that. I was looking for a cleaner and pure SwiftUI solution.

## The Discovery

After doing ~~hours~~ minutes of research, I concluded that the only pure SwiftUI implementation that could would know anything if a SwiftUI View was in a navigation controller was the `.toolbar` modifier... but not in the way I wanted. The `.toolbar` modifier adds the toolbar to a view **BUT ONLY** if its in a `NavigationView` or `NavigationStack` (as I mentioned before).

I started to wonder if I could use the `.toolbar` modifier as a detector of sorts. The toolbar content can take any view and views have a way to see if they appear so I thought I could use that to my advantage.

### Attempt 1: Using onAppear

My first attempt was simple. I wanted to see if using `.onAppear` would work. I knew that the `.toolbar` would get conditionally added based on if the view is in a `NavigationView` or `NavigationStack` so I added a `.onAppear` to some content in the toolbar.

Summary... it didn't work as I hoped. It turned out that the `.toolbar` would always call `.onAppear` for the content of the header no matter if it was in a `NavigationView` or not.

```swift
struct Attempt1View: View {

    var body: some View {
        Text("Something")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("")
                    .onAppear {
                        // I want this to only appear if the view is in a navigation controller
                        print("Please work")
                    }
                }
            }
    }
}

// Goal: I wanted "Please work" to print
// Result: It did print (yay)
struct InNavigationView: View {
    var body: some View {
        NavigationView {
            Attempt1View()
        }
    }
}

// Goal: I wanted "Please work" NOT to print
// Result: It DID print (not yay)
struct NoInNavigationView: View {
    var body: some View {
        Attempt1View()
    }
}
```

### Attempt 2: Using @Environment(\.isPresented)

`.onAppear` was a total lie. It actually isn't when the view visually appears. I guess its when the view is in some sort of UI hierarchy (not a SwiftUI expert here so take this for what it's worth).

I did soem more ~~Googling~~ ~~StackOverflowing~~ AI-ing and I found I could detect if a view appeared by using the `@Environment(\.isPresented)` environment variable.

It turns out... this was exactly what I wanted. I ended up creating a navigation detector! 🥳 But like... one that would only tell me if it it detected a navigation view through a print statement 😛 But hey, I could build upon this.

First, here is the `IShouldGoToBedView` that could do the navigation detection.

```swift
struct IShouldGoToBedView: View {
    @Environment(\.isPresented) private var isPresented

    var body: some View {
        Text("")
            .onChange(of: isPresented) { _, isPresented in
            if isPresented {
                print("Please work")
            }
        }
    }
}

struct Attempt2View: View {

    var body: some View {
        Text("Something")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    IShouldGoToBedView()
                }
            }
    }
}

// Goal: I wanted "Please work" to print
// Result: It did print (yay)
struct InNavigationView: View {
    var body: some View {
        NavigationView {
            Attempt2View()
        }
    }
}

// Goal: I wanted "Please work" NOT to print
// Result: It did NOT print (yay)
struct NoInNavigationView: View {
    var body: some View {
        Attempt2View()
    }
}
```

## The Solution (that I ended up with)

:warning: **Warning:** This solution is a bit of a hack and I'm **so proud** of it. I'm sharing it because I didn't see this solution anywhere else (probably for good reasons) but I think it's a fun solution and could _maybe_ be helpful to someone else.

### Usage

```swift
struct ContentView: View {
    var body: some View {
        // This will conditionally add a NavigationView around MyViewWithToolbar if needed
        NavigationViewIfNeeded {
            MyViewWithToolbar()
        }
    }
}
```

### Video Proof

<video width="100%" poster="/images/2025-02-08/navigation-if-needed-demo.png" controls>
  <source src="/images/2025-02-08/navigation-if-needed-demo.mp4" type="video/mp4">
Your browser does not support the video tag.
</video>

### Implementation

```swift
// This minimal view does a check if the view is visible rendered
struct ZeroFrameDetectionView: View {
    @Environment(\.isPresented) private var isPresented
    let didDetect: (Bool) -> Void

    @State private var hasReported = false

    var body: some View {
        Rectangle()
            .frame(width: 0, height: 0)
            .onChange(of: isPresented) { newValue in
                if newValue {
                    self.report(true)
                }
            }
            .onAppear {
                // Dispatch once after SwiftUI lay out
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.report(false)
                }
            }
    }

    private func report(_ value: Bool) {
        guard !self.hasReported else { return }
        self.hasReported = true
        self.didDetect(value)
    }
}

struct NavigationViewIfNeeded<Content: View>: View {
    enum Status {
        case unknown
        case inNav
        case notInNav
    }

    @State private var status: Status = .unknown

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        switch status {
        case .unknown:
            // This is where we wait for a (hopefully quick) response
            // if the view is in a navigation view or not
            Rectangle()
                .frame(width: 0, height: 0)
                .toolbar {
                    // Zero-sized detection view:
                    ZeroFrameDetectionView { isInNav in
                        // The first time we know the answer, store it
                        if status == .unknown {
                            status = isInNav ? .inNav : .notInNav
                        }
                    }
                }
        // If the view is in a navigation view, show the content directly
        case .inNav:
            content
                .onAppear {
                    print("✅ IN Navigation")
                }
        // If the view is not in a navigation view, wrap it in a navigation
        case .notInNav:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                // Using NavigationStack is best generic solution if only need
                // to show a toolbar
                // NavigatonStack toolbars combine nicely in parent NavigationView
                NavigationStack {
                    content
                        .onAppear {
                            print("❌ NOT IN Navigation")
                        }
                }
            } else {
                NavigationView {
                    content
                }
            }
        }
    }
}
```

### Full Test Suite (lol)

```swift
struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationViewIfNeeded {
                    Text("ewfawefaw")
                        .toolbar { // wont show without above ^^
                            Button(action: {

                            }) {
                                Text("Hey")
                            }
                        }
                }
            }
            .toolbar {
                Button(action: {

                }) {
                    Text("And another")
                }
            }
        }
    }
}
```

## The End

This is what it is. Code does what it does. There are guaranteed edge cases in this. The implementation of of `.toolbar` and `@Environment(\.isPresented)` could change from underneith me.

But I enjoyed problem solving this and I'm don't hate the solution. I've written worse code 🙃

Please let me know your thoughts on this. I'm curious if this is a good solution or if there is a better way to do this. But also PLEASE be nice 😊 As I've mentioned, I did this for fun, shared it for knowledge, and warned this is hacky.

That is all.

Love,
<br/>Josh

🍕 Also, please check if [Deep Dish Swift](https://deepdishswift.com/) if you want to attend a super fun, useful, and welcoming Swift and iOS conference! It's being help **April 27th to April 29th** this year in **Chicago, IL**. It's our third year and it's going to be a good one!

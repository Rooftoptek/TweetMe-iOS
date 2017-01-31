# Tweet{Me}

## Overview

Tweet{Me} is a fun social network that allows people to send a short message visible by all the community.
It is powered by Rooftop and is very easy to setup.
 
## Getting Started
Getting started with Tweet{Me} is very easy and necessitates only a few simple steps:
#### 1) Prerequisites
To run this demo, you will need a [Facebook application](https://developers.facebook.com/apps) and an account with [OneSignal](https://onesignal.com)
#### 2) Clone the project
- Clone the [repository](https://github.com/Rooftoptek/TweetMe.git) in a local directory
- In the root of the project, run

```ruby
pod install
```
#### 3) Configure the iOS app
- Open the workspace and go to the target TweetMe
- Enter your bundle id (or leave as is, but it must match the bundle id you used in the Facebook app)
- Select a team to sign the app
- Enter the Facebook app id in `Info.plist`
- Enter the Facebook URL scheme in `Info.plist`

#### 4) Create the Rooftop App
- Login to the Rooftop Console and create a new App called Tweet{Me}
- In settings, enable `Facebook authentication` and enter the Facebook app id
- In settings, enter the User Auth Key from your OneSignal account and enable the service
- Note your `Application Id` and `Cognito Pool Id`

#### 5) Configure the iOS SDK
- Open the `AppDelegate.m` file in xCode
- Fill in the `Application Id` and the `Cognito Pool Id` values for the configuration

#### 6) Test!
Fill free to Login, logout, and message everybody!
But wait, what is this error you get when you tap on a row?

This is the application trying to invoke a RAPID (Rooftop API Definition) function. Since no function has been defined yet, it's letting you know that there is a problem.

Let's add a RAPID from the console.

#### 7) RAPID
- In the console, select the `{R}Code` tab on the left
- Click on the `RAPID` section to expand it
- Click on the `+ Add` button
- Name the definition `message`
- Enter the following code:

```ruby
module.exports = function(input) {
  return `Your serverless backend
in the cloud.

You own it, we manage it!`;
}
```
- Click the `Save` button
- Click the `Deploy` button in the side bar

That's it!

Now, when you tap a row you get a message from your serverless backend in the cloud.

## Push notifications

We will update this section very soon to include push notifications.
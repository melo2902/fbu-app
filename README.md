# fbu-app
===

# ToDo List + Messages

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
A comprehensive To-Do list app that automatically pulls personal messages from various platforms (i.e. WeChat, Messenger, GroupMe) into to-do items. With the ability to quickly set notifications, the app will help reduce the user's pain point in having to remember to reply to messages. 

### App Evaluation
- **Category:** Productivity
- **Mobile:** This app is extremely mobile. It gives the users the convienence of replying to messages on the go, adding tasks whenever, and having a to-do list in their pocket. The app also heavily relies on push notifications to remind the users about their tasks. 
- **Story:** The value of the app is that users not longer have to remember to reply to messages, rather the app will remind the user for them. Additionally, the user will have the usual convenience of a to-do list. 
- **Market:** There potentially is a large market, since many people use to-do lists to keep track of their activities and people often has a large number of messages that they need to respond to. 
- **Habit:** This app can be very habit-forming if the user begins to rely on the app to complete their daily tasks and as a reminder to respond to their messages. 
- **Scope:** This app will be technically challenging because each messaging platform have a different API and style. Luckily, the general to-do list structure should be relatively straightforward, using knowledge from the Codepath Course. 

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- [ ] Users are able to create to-do items with notes and due dates associated with each item.
- [ ] The app automatically pulls in messages from at least one platform (GroupMe) with each conversation as an individual to-do items.
- [ ] Users are able to respond to messages that they recieve from at least one platform (GroupMe).
- [ ] Users will be able to quickly set reminders to reply to messages that they receive and items that they want to complete. 
- [ ] The app pre-creates lists (all, my day, tasks, messages) for the user. 

**Optional Nice-to-have Stories**

- [ ] Users are able to create multiple unique lists based on their own parameters (i.e. a school work list)
- [ ] An analytics page (either per list or in total) will be available for the users to analyze their productivity over time, and average completion/reply time for their items
- [ ] Users are able to connect to multiple messaging platforms.
- [ ] Users are able to add time (and total time for a list), files, photos, sub-steps, and other properties to their to-do items
- [ ] Users are able to use SIRI to log an item to complete

### 2. Screen Archetypes

* Login
   * Users are able to log into the app, with an optional sign up page. 
* Stream
   * Users are able to see the pre-defined lists and their created to-do lists.
* Detail List
    * Users can click on a list to see their to-do items, and messages. They are also able to create a new item. 
* Detail Task
    * Users can click on a to-do item to see its properties, either the conversation if it is a message or the due date/notes if it is an item
* Creation
    * Users can create new to-do items and reply to messages from the users. 
* Profile
    * Users are able to edit their username, email, the notification defaults, and add or remove integrated messaging platforms.

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* No tabs will be within the app

**Flow Navigation** (Screen to Screen)

* Stream
   * Tab on the left that allows users to change to a singular list to a list of all of the users' defined list.
   * Click on a to-do item to see the propertes of the item

## Wireframes
https://www.figma.com/file/dJDTHZxaAXNFm66MUXnUpJ/FBU-ToDo-Messaging-App?node-id=0%3A1

## Schema 
### Models
**To-Do Item**

| Property | Type | Description |
| ------------- | ------------- |------------- |
| item   | string     | The user's given description of the item to be completed|
| creation_date     | string       | When the item was created |
| status     | boolean       | Whether the to-do item has been completed|
| notification status     | String       | When the item's next reminder will be |
| due date     | date       | When the item needs to be completed by |
| notes     | string       | Any notes the user has on the to-do item |

**To-Do Messages**
| Property | Type | Description |
| ------------- | ------------- |------------- |
| message   | string     | The user's last message in a conversation|
| messages   | dictionary     | The user's messages in a conversation|
| creation_date     | string       | When the last message was sent |
| status     | boolean       | Whether the message has been replied to|
| notification status     | string       | When the message's next reminder will be |

### Networking
* Stream Screen
   * (READ/GET) Query all text messages from the accounts the user is connected to
   * (Create/POST) Create a new text message conversation or a new to-do item
* Detail Screen
   * (Create/POST) Reply to the text message and change the status of the message
* Profile
  * (READ/GET) Query logged in user object
  * (Update/PUT) Update user profile image

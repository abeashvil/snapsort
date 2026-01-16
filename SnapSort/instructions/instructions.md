# Recycling Helper App — Requirements Document

---

## 1. App Overview

This app helps people recycle correctly.  
A user takes a photo of their trash, and the app shows a list of items in the photo.  
Each item tells the user where it should go: **Recycle**, **Compost**, or **Trash**, plus a **confidence score** showing how sure the app is.  
The app is for everyday people who want quick, simple recycling help.

---

## 2. Main Goals

1. Make recycling decisions easy and fast.
2. Let users scan trash using their phone camera.
3. Show clear results in a simple list.
4. Explain how confident the app is about each item.
5. Keep the app easy to use and friendly.

---

## 3. User Stories

- **US-001**: As a user, I want to take a photo of my trash so that I don’t have to guess where items go.
- **US-002**: As a user, I want to see a list of items found in the photo so that I understand what the app detected.
- **US-003**: As a user, I want to see where each item should go so that I recycle correctly.
- **US-004**: As a user, I want to see a confidence score so that I know how sure the app is.
- **US-005**: As a user, I want to rescan if something looks wrong.

---

## 4. Features

- **F-001: Take Photo**
  - What it does: Opens the camera and lets the user take a photo.
  - When it appears: On the main screen.
  - If something goes wrong: Show a message like “Camera not available.”

- **F-002: Scan Photo**
  - What it does: Looks at the photo and finds items in it.
  - When it appears: After a photo is taken.
  - If something goes wrong: Show “Could not scan photo. Try again.”

- **F-003: Item List Results**
  - What it does: Shows a list of detected items.
  - When it appears: After scanning finishes.
  - If something goes wrong: Show “No items found.”

- **F-004: Recycling Decision**
  - What it does: Shows where each item goes (Recycle, Compost, Trash).
  - When it appears: Inside the results list.
  - If something goes wrong: Mark item as “Not sure.”

- **F-005: Confidence Score**
  - What it does: Shows a confidence level (example: High, Medium, Low).
  - When it appears: Next to each item.
  - If something goes wrong: Show “Low confidence.”

- **F-006: Rescan Button**
  - What it does: Lets the user take another photo.
  - When it appears: On the results screen.
  - If something goes wrong: Do nothing and stay on the screen.

---

## 5. Screens

- **S-001: Home Screen**
  - What’s on it: App title and “Scan Trash” button.
  - How to get there: App opens here.

- **S-002: Camera Screen**
  - What’s on it: Camera view and shutter button.
  - How to get there: Tap “Scan Trash” from S-001.

- **S-003: Loading Screen**
  - What’s on it: Loading message or spinner.
  - How to get there: After taking a photo.

- **S-004: Results Screen**
  - What’s on it: List of items, confidence score, and where each item goes.
  - How to get there: After scan finishes.

---

## 6. Data

- **D-001**: List of detected items (name, confidence score, destination).
- **D-002**: Last scanned photo (temporary).
- **D-003**: Scan date and time (optional).

---

## 7. Extra Details

- Needs internet to scan photos.
- Uses the iPhone camera.
- Does not need user accounts.
- Data is temporary and cleared when app closes.
- Supports dark mode automatically.
- Works in portrait mode only.

---

## 8. Build Steps

- **B-001**: Build S-001 and F-001 (Home screen and scan button).
- **B-002**: Build S-002 and connect camera access (F-001).
- **B-003**: Add S-003 loading screen and F-002 scan logic.
- **B-004**: Create D-001 to store scan results.
- **B-005**: Build S-004 using F-003, F-004, and F-005.
- **B-006**: Add F-006 rescan button to S-004.
- **B-007**: Handle basic errors and messages.
- **B-008**: Test app flow from S-001 to S-004.

---

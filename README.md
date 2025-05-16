# Ambulo – Your Smart Hiking Companion

Ambulo is an open-source Flutter-based hiking application that makes planning and navigating hikes easier, safer, and more enjoyable. It combines real-time trail alerts, personalized recommendations, weather forecasts, and a vibrant community all in one intuitive mobile app.



https://github.com/user-attachments/assets/fc544078-1ab3-472a-89c1-62d89e933499





## Table of Contents

- [Ambulo – Your Smart Hiking Companion](#ambulo--your-smart-hiking-companion)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Features](#features)
  - [User Guide](#user-guide)
    - [Using the App (APK)](#using-the-app-apk)
  - [Screenshots](#screenshots)
  - [Architecture \& Technology](#architecture--technology)
  - [References](#references)

---

## Overview

Ambulo is designed to streamline every part of the hiking experience:

* Plan personalized routes based on difficulty, length, terrain, weather, and more.
* Navigate trails using interactive maps and GPS tracking.
* Receive real-time information about hazards, weather shifts and other waypoints.
* Share your experiences and photos with a growing community of hikers.

The app is cross-platform, supporting Android and web, and offers seamless cloud sync and offline access.


## Features

* ✅ **Personalized Route Suggestions** using hybrid recommendation algorithms
* 🗺️ **Interactive Maps** with real-time positioning and terrain overlays
* 🌦️ **Weather Forecasts** (5-day forecast)
* 💬 **Community Section** – Reviews, photo uploads, and trail suggestions
* 🚨 **Safety Features** – Real-time hazard alerts and risky points.
* 🎮 **Gamification** – User progression and contribution scoring
* 🔒 **Secure Authentication** –  Firebase auth

## User Guide

### Using the App (APK)

**For regular users (no technical skills required):**

1. Download the latest APK from the [Releases Page](https://github.com/Danielbet21/Ambulo/releases)
2. Install it on your Android device (you might need to enable *Install from Unknown Sources*)
3. Sign in with your Email
4. Browse and plan a hike based on filters like distance, difficulty, water access, etc.
5. Use real-time GPS navigation and alerts during your hike
6. Review trails and upload photos to help others


## Screenshots

* Home screen
* Route search and filters
* Trail preview and navigation
* Weather alerts
* Community page

*(Add actual images to `/screenshots/` and embed here.)*

---

## Architecture & Technology

Ambulo uses a **SaaS-based** architecture with the following components:

* **Frontend**: Flutter (Dart) for both Android & Web
* **Backend**: Flutter (Dart), Firebase Cloud Functions + Firestore
* **Auth**: Firebase Authentication
* **Mapping**: GPX rendering + Google Maps + Isreal hiking map
* **CI/CD**: GitHub + GitHub Actions

Diagrams:

* [High-Level Architecture](https://github.com/Danielbet21/Ambulo/blob/main/Documents/SVG/High-level%20architecture%20diagram.svg)
* [Class Diagram](https://github.com/Danielbet21/Ambulo/blob/main/Documents/SVG/Ambulo%20class%20diagram.svg)
* [Database Schema](https://github.com/Danielbet21/Ambulo/blob/main/Documents/SVG/Database%20diagram.svg)


## References

* 📄 [Ambulo Development Notes (Technical)](https://github.com/Danielbet21/Ambulo/blob/main/Ambulo%20Development.md)
* 📄 [Statement of Work (Technical)](https://github.com/Danielbet21/Ambulo/blob/main/Documents/Statement%20of%20Work.pdf)
* 🌐 [Israel Hiking Map (Open Source)](https://github.com/IsraelHikingMap)

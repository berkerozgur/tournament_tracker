# 🏆 Tournament Tracker

**Tournament Tracker** is a cross-platform Flutter desktop application that helps manage and track tournament events. It offers a clean UI for organizing participants, processing matches, and sending out match updates via email — configurable for both local and real SMTP setups.

> 💬 This app is a Flutter re-implementation of a [C# desktop series by Tim Corey](https://www.youtube.com/playlist?list=PLLWMQd6PeGY3t63w-8MMIjIyYS7MsFcCi). Full credit to Tim for the project concept and original implementation.

---

## 🚀 Features

- 📝 Create and manage tournament participants
- 🔄 Process rounds and display match results
- 📧 Send match updates via email (using configurable SMTP settings)
- 🖥️ Built for desktop platforms (Windows/Linux/macOS)

---

## 🛠 Built With

- **Flutter** – Modern UI framework for cross-platform apps
- **mailer** – Email functionality (SMTP client)
- **flutter\_dotenv** – Load environment variables from a file
- **decimal**, **path**, **path\_provider** – Utility libraries to support logic and storage

---

## 🔐 Environment Variables

This app uses [flutter\_dotenv](https://pub.dev/packages/flutter_dotenv) to configure local email behavior via a `.env` file.

Example (excluded from version control):

```
EMAIL=demo@example.com
PASSWORD=not_used_in_demo
```

You can use tools like [smtp4dev](https://github.com/rnwood/smtp4dev) for local development/testing.

---

## 💡 Notes

- Real email sending works if valid SMTP credentials and host are provided
- The layout is currently optimized for desktop use only
- No backend or authentication system is included — this is a standalone client app


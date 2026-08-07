# Clearing Gradle Cache on Windows

If you encounter Gradle build errors, corrupted dependencies, or cache-locking issues in your Flutter Android build, follow these steps to completely clear the Gradle cache on your Windows PC.

---

## 1. Project-Level Clean

Before deleting global caches, perform a clean on the project's build directories.

### Using Flutter CLI (Recommended)
Run this command from the root of your Flutter project:
```powershell
flutter clean
```

### Or Using Gradle Wrapper directly
Navigate to the `android` folder and run the clean task:
```powershell
cd android
.\gradlew clean
```

---

## 2. Stop the Gradle Daemon

Gradle runs in the background as a daemon. To prevent file-in-use locks when deleting cache folders, stop all active Gradle daemons:

```powershell
cd android
.\gradlew --stop
```

---

## 3. Delete Global Gradle Cache Folders

The global Gradle cache is stored in your user profile directory under `.gradle`. Deleting the `caches` subfolder will force Gradle to re-download all dependencies on the next build.

### Using PowerShell (Recommended)
Run the following command:
```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches"
```

### Using Command Prompt (CMD)
Run the following command:
```cmd
rmdir /s /q "%USERPROFILE%\.gradle\caches"
```

---

## 4. Delete Gradle Wrapper Distributions (Optional)

If you suspect the Gradle build tool itself is corrupted, you can delete the Gradle wrapper distributions folder to force a re-download of the Gradle tool:

### Using PowerShell
```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\wrapper\dists"
```

### Using Command Prompt (CMD)
```cmd
rmdir /s /q "%USERPROFILE%\.gradle\wrapper\dists"
```

---

## 5. Rebuild the Project

Once you have deleted the cache folders, go back to your Flutter project root and run your build command. Gradle will automatically re-download all required plugins, libraries, and wrappers:

```powershell
flutter pub get
flutter run -d <your-device-id>
```

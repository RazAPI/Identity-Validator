# Luau Identity Validator

Checks and validates the thread identity of your RSU.

**Latest Version:** 2.0.1 (Build 4120269P)

---

## Requirements
The following functions must be available:

```
debug.info
getthreadidentity
setthreadidentity
```

> If you're using a custom debug library, make sure `debug.info` is implemented.

---
## Configuration

The validator uses a global configuration table:
```lua

getgenv().ValidatorConfiguration
--// or
getfenv(0).ValidatorConfiguration
```
### Available Settings

* `ValidatorConfiguration.DisplayTimeTaken`
&#x20; Displays how long each test takes (in milliseconds).
&#x20; Divide by 1000 to convert to seconds.
If no configuration is found, it will be created automatically.
---
## Error Codes
### Dependencies

* `0x1C`
&#x20; Missing a required dependency or function.
&#x20; → Check the **Requirements** section.
---
### Test Dependencies
* `0x7C`
&#x20; A function used in a test is present but not working correctly.
* `0x3C`

&#x20; A function required for a test is missing.
---
### Validator Runtime
* `0x8F`
&#x20; Failed to find configuration settings.
&#x20; This does **not** affect test results, defaults will be applied.
* `0x6F`
&#x20; Failed to calculate execution time for tests
&#x20; (`ValidatorConfiguration.DisplayTimeTaken`).
---
## About Error Code Labels
Error codes are grouped into "families" that indicate where the issue occurred.

* Codes ending in `C` → **Dependencies / Test Dependencies**
* Codes ending in `F` → **Validator Runtime**

These families help identify which part of the validator is causing the issue.

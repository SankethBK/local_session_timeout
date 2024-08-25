
## 0.0.1 

* Initial release

## 0.1.0

* Removed unnecessary dependencies

## 0.2.0

* added dispose method to close the stream

## 1.0.0

* Introduced SessionStateStream to disable and re-enable session timeout manager.
* **\[Breaking]** Changed variable name _updateUserActivityWindow_  to _userActivityDebounceDuration_

## 2.0.0

* Extended support for Flutter 3

## 2.1.1

* Bug fix (listener not working when it is stopped and started again)

## 2.1.2

* Fixed typo ~~invalidateSessionForUserInactiviity~~ -> invalidateSessionForUserInactivity

## 2.2.0

* Fixed a bug related to null check

## 2.3.0

* Bugfix: setState getting called after SessionTimeoutManager is removed from widget tree

## 2.3.1

* Changed default of `userActivityDebounceDuration` to 1 second as it leads to common bugs

## 2.3.2

* Removed state because of issues in GetX

## 3.0.0

* Fixed an issue where `appFocusTimeout` was not emitted on higher versions of Android. This occurred because the process was being terminated by the OS due to battery optimization settings. The latest version takes a more passive approach to determine if the duration has paassed after app has lost focus which ensures `appFocusTimeout` will always be emitted regardless of battery optimization

## 3.1.0

* Fixed an issue where `appFocusTimeout` wasn't pushed because of a bug related to timer.

## 3.2.0

* Fixed an issue related to `_appLostFocusTimestamp`, where the timer was not resetting when app regained focus.
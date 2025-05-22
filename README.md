# recipe_demo_flutter

first of all, thx for the feedback.
based on the feedback given what i have done for the changes is that:

-App is super laggy for unknown reason.
  - i noticed there are alot of jank load when i tried to view the app performance through dart: devtools by running in profile mode, for this what i have done is that, i added cachewidth for those image asset to optimize the image loads as much as possible, at the same time i've also addon 'repaintboundary' widget wipe for expensive widget. and also tried removal of those unwanted lines and logging.
  - i've try optimise a bit of image quality to medium setting. if the uploaded image quality is high enough to be present, high setting might not be needed.
- basic ui
  - what i've done is that, i further add on some theme color and emojis for better ui looking
  - little loading screen and bottom navigation bar for better responsiveness.
- overlay issue at the filter and search section
  - i've add on, mediaquery checking, if maxwidth is not greater than 390, i will present it in Column approach, otherwise will remain row.
 
  - addtionally, i've made a little configuration on ios build and it is ready to build and run. kindly pod install after flutter pub get; use xcode -> open runner.xccodeworkspace -> try and see whether it can compile.
  - a validator file, to better scale if any new fields for recipe comming in.

kindly use main branch for review purpose.

once again, thx for the oppotunity. 
jia sian

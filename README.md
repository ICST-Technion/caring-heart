# Nivapp

Nivapp is a system for managing the [resources center] at [Lev Chash] (מרכז המשאבים בלב ח"ש),
which is a non-profit organization. Donors donate furniture items, which are collected from their house with a truck and then delivered to the resource center, where the items are listed for sale for affordable prices.

## Components
- [Firebase database] 
  - inventory - all items (donations) with address, contanct, item description and status.
  - routes - list of where to stop and when for drivers to collect donations per day.
  - reports - what the drivers reported that they collected for every submitted donation.
- Google sheets interface for editing the inventory of the firebase ([test sheets], [production sheets]).
  - isChecked flag - whether the information (s.t address) was verified by Lev Chash
  - isCollected flag - after the drivers report that they collexted some donation, this turns true.
- [Google Forms] - form for doners, that automatically adds a dontation to the database. 
- [Planner Interface] - web based interface for the planner that plans daily routes for the driver.
  - Define the times of collection of donations per day.
  - This updates routes in the database.
  - Can only put donation that are checked and are not collected yet.
- [Drivers Interface] - web based interface for the driver that picks up the donations.
  - View the order of picking up the donations.
  - View information about each donation - phone, address, items description, etc.
  - Report what was actually collected (or not).

caringhearttech@gmail.com is the account connected to all google services.
For usernames, passwords and private keys please contanct the team of last year of the yearly software engineering project at the Technion. 

## Planner & Drivers Interfaces
We used [Flutter] to develop both interfaces under the same project located in /nivapp directory.
First download flutter, then run in `/nivapp`:
```sh
flutter pub get
flutter upgrade  # might not be necessary
flutter pub upgrade  # might not be necessary
```
To view the interfaces locally run:
```sh
flutter run -d chrome
```
The project should now be opened in a new Chrome window. You should wait for it to load,
this might take some time loading for the first time.
Then add `/#/drivers` or `/#/planner` to the URL in the chrome to open the drivers interface or planners interface respectively.
### Deployment
Download [Firebase CLI] and login.
run in `/nivapp`:
```sh
flutter build web
firebase deploy --only hosting
```
### Structure
Partial tree:
```
nivapp/
|- lib/
    |- driver_interface/
    |- route_planner/
    |- services/  # DB services
    |- widgets/  # UI for both planner & drivers
    |- main.dart  # main app
    |- production_module.dart  # production configuration
    |- offline_mock_module.dart  # test configuration
|- test/
```
`main.dart` runs both the drivers and the planner interfaces.
It defines the configuration of the project with the `injector` field, which is used by
UI widgets to access services that communicate with the database.

### Dependency Injection & State Management
We use *Dependency Injection* to connect between the database, authenication, and extra configurations to the UI. This way we can our code less interconnected and more testable.
The library that is used for that is [flutter_simple_dependency_injection].
We have two seperate configurations
 - `production_module.dart` - connects to actual firebase firestore database + auth. 
 - `offline_mock_module.dart` - Works offline without connection to Firebase. defines dummy data for inventory, routes and reports. There is no auth in that module.


For state management we use [provider]. For each interface, drivers and planner, we have a corresponding *provider* that manages the state for the interface.

### Testing
Tests are under `/test` directory.
Run tests with:
```sh
flutter test
```
For testing purposes we use *mock*s that imitate real objects with [mockito].
The mocks are defined in `/lib/mock_definitions.dart`. See docs there.
We also use fake firebase implementation with [fake_cloud_firestore].

## Google Sheets ↔  Firebase Sync
The Google Sheets holds only the inventory (see above), and should be the source of truth for the inventory.
Google Sheets → Firebase Sync is done with  [Google AppsScript], and Firebase → Google Sheets is done with  [Firebase Cloud Functions].
The spreadsheet is separated by sheets, one for each month. A new sheet is created every 
month with a time-driven trigger in the AppsScript enviroment.
There are two hidden columns in the spreadsheet. The first is ID, which is the firebase key of the item corresponding to the row in sheets. That way we connect between a row and an item in Firebase.  
### Google Sheets to Firebase Sync
The code is found under `/appscript`, and the `Code.js` is the main file.
`constants.js` holds the google sheets columns order, and more such as required columns.
It is deployed to both enviroments, [production apps-script] (connected to [test sheets]),
and [testing apps-script] (connected to [production sheets]). In the enviroments you can see triggers and logs.
The Google Form code is also found here.
##### Deployment to AppsScript
The deployemnt is done with [multi-clasp2] which runs [clasp] push command for both enviroments.
After installing [clasp] and [multi-clasp2], run:
```sh
multi-clasp push
```

### Firebase Sync to Google Sheets
Code is found under `firebase/` directory. `constants.js` is the same as in the previous section **and must be identical**.
##### Deployment to Firebase
Deployment requires the file `serviceAccount.json` which holds a private key and should be under `firebase\functions` directory. Ask the previous team members for this one, or create it yourself in the Google Cloud project which is connected to Firebase.
After adding `serviceAccount.json`, run:
```sh
flutter deploy --only functions
```
### Google Forms to Firebase
When a form is submitted, a row is added to [production sheets] in some hidden sheet.
Pay attention that changing form questions might result in the change of columns in that sheet.
If that happens you need to change `FORM_FIELDS` field in `constants.js`.
Then the code in `appscript\formSubmit.js` uploads the data to Firebase (it is connected to the form with a trigger in the AppsScript enviroment).

## Multiple declerations of Item (donation) fields
The fields of an item are hard-coded in multiple places, so changing them is hard.
The fields are defined in:
- Google Sheets - the columns themselves
- Firebase - we don't have a code for adding / removing fields from existing items.
- Flutter - under `nivapp/lib/item_spec.dart`.
- AppsScript and Firebase Cloud Functions - in the `constants.js` file of both.
- AppsScript - the columns of the sheet of the form answers - in `constants.js` in `FORM_FIELDS` field, see above for details.

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)
    
   [Lev Chash]: <https://levchash.co.il/>
   [resources center]: <https://levchash.co.il/%d7%9e%d7%a8%d7%9b%d7%96-%d7%a8%d7%99%d7%94%d7%95%d7%98/>
   [Firebase database]: <https://console.firebase.google.com/project/caring-heart-tech/>
   [test sheets]: <https://docs.google.com/spreadsheets/d/1X1q6YAQdXoEmkUn2KhygDzswDlwZ8epW2NL3jSu1tj0>
   [production sheets]: <https://docs.google.com/spreadsheets/d/10b4vqS0cbBlqLuDGgSyOljJaCziwTYyHfReQq6jdRdg>
   [Google Forms]: <https://docs.google.com/forms/d/e/1FAIpQLScoq7UPvlKpmD6kLsnNRXBgMJbxMuReCb_OrrmPM3UqeEwTgg/viewform>
   [Planner Interface]: <https://nivapp.web.app/#/planner>
   [Drivers Interface]: <https://nivapp.web.app/#/drivers>
   [Flutter]: <https://flutter.dev/>
   [Firebase CLI]: <https://firebase.google.com/docs/cli>
   [flutter_simple_dependency_injection]: <https://pub.dev/packages/flutter_simple_dependency_injection>
   [provider]: <https://pub.dev/packages/provider>
   [mockito]: <https://pub.dev/packages/mockito>
   [fake_cloud_firestore]: <https://pub.dev/packages/fake_cloud_firestore>
   [Google AppsScript]: <https://developers.google.com/apps-script>
   [Firebase Cloud Functions]: <https://firebase.google.com/docs/functions>
   [production apps-script]: <https://script.google.com/home/projects/1vx3hBl63JhbTnpvd1Uv0-qGm7qoo08m2ZroMruMwvSSMFVVYWEv-x8cM/triggers>
   [testing apps-script]: <https://script.google.com/home/projects/1rzd_-tv24g6pycV8C1t6begTGBdDPSBEcxd6JSuXmOxcjnXvgrUy8jFI/edit>
   [multi-clasp2]: <https://www.npmjs.com/package/multi-clasp2>
   [clasp]: <https://developers.google.com/apps-script/guides/clasp>
   

# Dialogue
The better way to message.


## For Developers

### Setup/Use of Cocoapods cheatsheet
1. Make sure cocoapods is installed, run the following command to install
```
sudo gem install -n usr/local/bin cocoapods
```
2. Make sure your development environment is updated with the latest pod setup, run the following command in the XCode project directory to install needed dependencies from the `Podfile`
```
pod install
```
3. To add dependencies simply add them to the `Podfile` in the XCode project by adding a line like:
```
# Pod for Dialogue
...
pod 'Example/Pod'
```

### For error saying "Could not build Objective-C module 'Firebase'"
Run these commands to alleviate this error:
```
1. rm -rf ~/Library/Developer/Xcode/DerivedData
2. rm -rf Dialogue.xcworkspace/
3. rm -f Podfile.lock
4. rm -rf Pods/
5. pod install
```
Reopen the project.

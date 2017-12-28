# NFCNDEFParse

NFC Forum Well Known Type Data Parser for iOS11 and Core NFC.

Supports parsing of types:

Text - NFCForum-TS-RTD_Text_1.0 2006-07-24

Uri - NFCForum-TS-RTD_URI_1.0 2006-07-24

Smart Poster - NFCForum-SmartPoster_RTD_1.0 2006-07-24 (title, uri, action, size)

## Requirements

Core NFC requires iOS11 (and Xcode 9)

## Installation

NFCNDEFParse is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod 'NFCNDEFParse'
```

## Usage

**Note: For non CocoaPods usage and more details see Examples!**

### Import the library.

Swift:

```
import NFCNDEFParse
```

Objective-C:

```
@import NFCNDEFParse;
```

### Create array for the messages

```
var data: [NDEFMessageWithWellKnownTypes] = []
```

### In CoreNFC callback create the "well know types" data array.

```
func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    data = messages.flatMap({ NDEFMessageWithWellKnownTypes(records: $0.records) })
}
```

### Loop through the data array to print out the values.

```
data.forEach({ message in
    print("message: ")
    message.records.forEach({ record in
        print(record.description)
    })
})

```

## Author

Jari Kalinainen, jari@klubitii.com

## License

NFCNDEFParse is available under the MIT license. See the LICENSE file for more info.

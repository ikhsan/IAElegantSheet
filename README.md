# IAElegantSheet

Another UIActionSheet but more elegant. Elegant to code and elegant to see. Using Roboto Condensed as default font. 

## Urgh, another block based UIActionSheet?
Yes! :) We can't get enough of block based handler for replacing default UIKit. I've built it for my current project and I want to learn how to built default action sheet around block handlers.

Currently still WIP though.

## Preview
![image](https://dl.dropboxusercontent.com/u/10627916/elegantsheet-portrait.png)
![image](https://dl.dropboxusercontent.com/u/10627916/elegantsheet-landscape.png)

## Requirements

- iOS 6.0


## Usage

Import the header, create sheet, add buttons, add handler and show it :

````objc
#import "IAElegantSheet.h"


IAElegantSheet *elegantSheet = [IAElegantSheet 
elegantSheetWithTitle:@"Elegant Sheet"];
[elegantSheet addButtonsWithTitle:@"Elegant to code" block:^{
		code.isElegant = YES;
}];
[elegantSheet addButtonsWithTitle:@"Elegant to see" block:^{
		sheet.isElegant = YES;
}];
[elegantSheet addButtonsWithTitle:@"Custom font by default" block:^{
		font = @"Roboto";
}];
[elegantSheet setCancelButtonWithTitle:@"Thanks!" block:nil];
[elegantSheet showInView:self.view];
````

## License

IAElegantSheet is provided under the MIT license.  See LICENSE for specifics.

## Attribution

Created as part of the Objective-C Hackathon on June 29th, 2013.
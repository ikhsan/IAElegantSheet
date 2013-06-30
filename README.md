# IAElegantSheet

Another UIActionSheet but more elegant. Elegant to code and elegant to see. Using Roboto Condensed as default font. 

## Urgh, another block based UIActionSheet?
Yes! :) We can't get enough of block based handler for replacing default UIKit. I've built it for my current project and I want to learn how to built default action sheet around block handlers.

Currently still WIP though.


## Requirements

- iOS 6.0


## Usage

Import the header, create sheet, add buttons, add handler and show it :

````objc
#import "IAElegantSheet.h"


IAElegantSheet *elegantSheet = [IAElegantSheet 
elegantSheetWithTitle:@"How awesome you are?"];
[elegantSheet addButtonsWithTitle:@"Awesome" block:^{
		[you setAwesomeness:5];
}];
[elegantSheet addButtonsWithTitle:@"Awesomer" block:^{
		[you setAwesomeness:8];
}];
[elegantSheet addButtonsWithTitle:@"Awesomest" block:^{
		[you setAwesomeness:10];
}];
[elegantSheet setCancelButtonWithTitle:@"Nevermind!" block:nil];
[elegantSheet showInView:self.view];
````

## License

IAElegantSheet is provided under the MIT license.  See LICENSE for specifics.

## Attribution

Created as part of the Objective-C Hackathon on June 29th, 2013.
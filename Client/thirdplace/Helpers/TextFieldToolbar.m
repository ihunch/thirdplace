//
// Created by David Lawson on 28/06/2014.
// Copyright (c) 2014 Snaptch. All rights reserved.
//

#import "TextFieldToolbar.h"

@interface TextFieldToolbar ()

@property (nonatomic, strong) UIBarButtonItem *prevButton, *nextButton, *space, *doneButton;

@end

@implementation TextFieldToolbar

- (id)initWithTextFields:(NSArray *)textFields
{
    self = [super init];
    if (self)
    {
        [self sizeToFit];

        self.textFields = textFields;

        self.space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemFlexibleSpace)
                                                                   target:nil
                                                                   action:nil];

        self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                           style:UIBarButtonItemStyleBordered target:self
                                                          action:@selector(doneClicked:)];

        if (self.textFields.count > 1)
        {
            self.prevButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous"
                                                               style:UIBarButtonItemStyleBordered target:self
                                                              action:@selector(previousClicked:)];

            self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                               style:UIBarButtonItemStyleBordered target:self
                                                              action:@selector(nextClicked:)];

            [self setItems:@[self.prevButton, self.nextButton, self.space, self.doneButton]];
        }
        else
        {
            [self setItems:@[self.space, self.doneButton]];
        }

        for (UITextField *textField in self.textFields)
        {
            if ([textField respondsToSelector:@selector(addTarget:action:forControlEvents:)])
                [textField addTarget:self action:@selector(beganEditing:) forControlEvents:UIControlEventEditingDidBegin];
        }
    }

    return self;
}

- (void)previousClicked:(id)previousClicked
{
    UITextField *prev = nil;
    for (UITextField *textField in self.textFields)
    {
        if (textField.isFirstResponder) break;
        prev = textField;
    }

    [prev becomeFirstResponder];
}

- (void)nextClicked:(id)nextClicked
{
    UITextField *prev = nil;
    for (UITextField *textField in self.textFields)
    {
        if (prev.isFirstResponder)
        {
            [textField becomeFirstResponder];
            break;
        }

        prev = textField;
    }
}

- (void)doneClicked:(id)doneClicked
{
    for (UITextField *textField in self.textFields)
    {
        if (textField.isFirstResponder)
        {
            [textField resignFirstResponder];
            break;
        }
    }
}

- (void)beganEditing:(UITextField *)field
{
    self.nextButton.enabled = self.textFields.lastObject != field;
    self.prevButton.enabled = self.textFields[0] != field;
}
@end
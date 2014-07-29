//
// Created by David Lawson on 28/06/2014.
// Copyright (c) 2014 Snaptch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TextFieldToolbar : UIToolbar

@property (nonatomic, strong) NSArray *textFields;

- (id)initWithTextFields:(NSArray *)textFields;
- (void)beganEditing:(UITextField *)field;

@end
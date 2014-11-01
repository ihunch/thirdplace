//
// Created by David Lawson on 4/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import "AddFriendViewController.h"
#import "DZNPhotoPickerController.h"
#import "Friend.h"
#import "UIImagePickerControllerExtended.h"
#import "RootEntity.h"
#import "TextFieldToolbar.h"
#import <RHAddressBook/AddressBook.h>
#import <NYXImagesKit/UIImage+Saving.h>

@interface AddFriendViewController ()
        <ABPeoplePickerNavigationControllerDelegate,
        UINavigationControllerDelegate,
        UIActionSheetDelegate,
        UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;

@property (nonatomic, strong) RHAddressBook *addressBook;
@property (nonatomic, strong) RHPerson *selectedPerson;

@end

@implementation AddFriendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.firstNameTextField.inputAccessoryView =
            self.lastNameTextField.inputAccessoryView =
                    self.emailTextField.inputAccessoryView =
                            self.mobileTextField.inputAccessoryView =
                                    [[TextFieldToolbar alloc] initWithTextFields:@[
                                            self.firstNameTextField,
                                            self.lastNameTextField,
                                            self.emailTextField,
                                            self.mobileTextField
                                    ]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)pressedLoadFromContacts:(id)sender
{
    self.addressBook = [[RHAddressBook alloc] init];

    if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusNotDetermined)
    {
        //request authorization
        [self.addressBook requestAuthorizationWithCompletion:^(bool granted, NSError *error) {
            if (granted) {
                [self showContactPicker];
            }
        }];
    }
    else
    {
        [self showContactPicker];
    }
}

- (void)showContactPicker
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.displayedProperties = @[[NSNumber numberWithInt:kABPersonPhoneProperty]];

    [self presentViewController:picker animated:YES completion:nil];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)personRef
{
    self.selectedPerson = [self.addressBook personForABRecordRef:personRef];
    self.firstNameTextField.text = self.selectedPerson.firstName;
    self.lastNameTextField.text = self.selectedPerson.lastName;
    self.imageView.image = self.selectedPerson.originalImage;

    if (self.selectedPerson.emails.count > 0)
        self.emailTextField.text = [self.selectedPerson.emails valueAtIndex:0];

    if (self.selectedPerson.phoneNumbers.count > 0)
    {
        return YES;
    }
    else
    {
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    unsigned index = [[self.selectedPerson getMultiValueForPropertyID:property] indexForIdentifier:identifier];
    self.mobileTextField.text = [[self.selectedPerson getMultiValueForPropertyID:property] valueAtIndex:index];
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

- (IBAction)pressedSelectPhoto:(id)sender
{
    UIActionSheet *actionSheet = [UIActionSheet new];
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] || [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Take Photo", nil)];

    [actionSheet addButtonWithTitle:NSLocalizedString(@"Choose Photo", nil)];

    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)]];
    [actionSheet setDelegate:self];

    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

    if ([buttonTitle isEqualToString:NSLocalizedString(@"Take Photo", nil)])
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Choose Photo", nil)])
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    picker.cropMode = DZNPhotoEditorViewControllerCropModeCircular;

    picker.finalizationBlock = ^(UIImagePickerController *_picker, NSDictionary *info)
    {
        if (_picker.cropMode != DZNPhotoEditorViewControllerCropModeNone)
        {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            DZNPhotoEditorViewController *editor = [[DZNPhotoEditorViewController alloc] initWithImage:image cropMode:_picker.cropMode];
            [_picker pushViewController:editor animated:YES];
        }
        else
        {
            [self updateImageWithPayload:info];
            [_picker dismissViewControllerAnimated:YES completion:nil];
        }

    };

    picker.cancellationBlock = ^(UIImagePickerController *picker)
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    };

    [self presentViewController:picker animated:YES completion:nil];
}

- (void)updateImageWithPayload:(NSDictionary *)payload
{
    UIImage *image = [payload objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [payload objectForKey:UIImagePickerControllerOriginalImage];

    self.imageView.image = image;
}

- (IBAction)pressedAdd:(id)sender
{
    Friend *friend = [Friend MR_createEntity];
    friend.firstName = self.firstNameTextField.text;
    friend.lastName = self.lastNameTextField.text;
    friend.mobileNumber = self.mobileTextField.text;
    friend.email = self.emailTextField.text;

    if (self.imageView.image)
    {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *subfolder = [documentsDirectory stringByAppendingPathComponent:@"profile_pictures"];

        NSError *error;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:subfolder withIntermediateDirectories:YES attributes:nil error:&error];

        if (success)
        {
            NSString *dest = [subfolder stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
            success = [self.imageView.image saveToPath:dest];
            if (success)
                friend.imagePath = dest;
        }
    }

    int x = arc4random_uniform((u_int32_t)(self.view.frame.size.width));
    int y = arc4random_uniform((u_int32_t)(self.view.frame.size.height));
    friend.xValue = x; friend.yValue = y;

    [[RootEntity rootEntity].friendsSet addObject:friend];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [self.delegate didAddFriend:friend];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
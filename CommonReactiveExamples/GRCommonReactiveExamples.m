//
//  GRCommonReactiveExamples.m
//  GroupChat
//
//  Created by kanybek on 8/4/15.
//  Copyright (c) 2015 Grouvi. All rights reserved.
//

#import "GRCommonReactiveExamples.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface GRCommonReactiveExamples ()
@property (nonatomic, copy) NSString *testString;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *passwordConfirmation;
@property (nonatomic, copy) NSString *flattenTestString;

@property(nonatomic, weak) UIButton *createButton;
@property(nonatomic, weak) UITextField *firstNameField;
@property(nonatomic, weak) UITextField *lastNameField;
@property(nonatomic, weak) UITextField *emailNameField;

@property(nonatomic, assign) BOOL cancelled;
@end


@implementation GRCommonReactiveExamples



- (void)racSignalExamples
{
    UIImage *image = [UIImage imageNamed:@"icon_MediaNotLoaded.png"];
    [[SDImageCache sharedImageCache] storeImage:image forKey:@"qwertyqwerty"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        NSURL *urlString = [[NSURL alloc] initWithString:@"qwertyqwerty"];
        
        [imageView sd_setImageWithURL:urlString placeholderImage:nil completed:
         ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
             NSLog(@"%@", image);
         }];
    });
}


- (void)racSequenceExamples
{
    
    RACSignal* signalForTestSendCompleted = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"World signal22"];
        [subscriber sendCompleted];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"someLongRunningOperationSignal"];
        });
        return nil;
    }];
    
    [signalForTestSendCompleted subscribeNext:^(NSString *stringForTest) {
        NSLog(@"%@",stringForTest);
    }];
    
    
    //Simple example
    //More examples
    //https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/Legacy/BasicOperators.md
    
    //    _twitterLoginCommand = [[RACCommand alloc] initWithSignalBlock:^(id _) {
    //        @strongify(self);
    //        return [[self
    //                 twitterSignInSignal]
    //                takeUntil:self.cancelCommand.executionSignals];
    //    }];
    //    
    //    RAC(self.authenticatedUser) = [self.twitterLoginCommand.executionSignals switchToLatest];
    
    RACSignal* someLongRunningOperationSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //someLongRunningOperationSignal
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"someLongRunningOperationSignal"];
            [subscriber sendCompleted];
        });
        
        return nil;
    }];
    
    RACSignal *someLongRunningWithCancelSignal = [someLongRunningOperationSignal takeUntil:[RACObserve(self, cancelled) ignore:@NO]];
    
    [someLongRunningWithCancelSignal subscribeNext:^(NSString *x) {
        NSLog(@"%@",x);
    }];
    
    NSUInteger seconds = 8;
    //NSUInteger seconds = 11;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.cancelled = YES;
    });
    
    
    NSArray *stringsArray = @[ @"A", @"B", @"C" ];
    RACSequence *sequence = [stringsArray.rac_sequence map:^(NSString *str) {
        return [str stringByAppendingString:@"_"];
    }];
    
    NSLog(@"%@",sequence.head);
    NSLog(@"%@",sequence.tail.head);
    NSLog(@"%@",sequence.tail.head);
    
    
    RACSignal* signal11 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"Hello signal11"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    
    
    RACSignal* signalMulticast = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"INITIALIXING");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"Hello signal11"];
            [subscriber sendCompleted];
        });
        
        return nil;
    }];
    
    /* if we are not using multicast here, every time when we call recreating of signal,
     *  then it may cost for us very expensive
     *
     */
    //    [signalMulticast subscribeNext:^(id x) {
    //        NSLog(@"1%@",x);
    //    }];
    //
    //    [signalMulticast subscribeNext:^(id x) {
    //        NSLog(@"2%@",x);
    //    }];
    //
    //    [signalMulticast subscribeNext:^(id x) {
    //        NSLog(@"3%@",x);
    //    }];
    
    /* By using  multicast signal, block calls only onnce
     * then evetu subscriber will imediately use calculated response.
     *
     */
    
    RACMulticastConnection *multicast = [signalMulticast publish];
    [multicast connect];
    
    [multicast.signal subscribeNext:^(id x) {
        NSLog(@"1%@",x);
    }];
    
    [multicast.signal subscribeNext:^(id x) {
        NSLog(@"2%@",x);
    }];
    
    [multicast.signal subscribeNext:^(id x) {
        NSLog(@"3%@",x);
    }];
    
    RACSignal* signal22 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"World signal22"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^(){
            
        }];
    }];
    
    [[signal11 doNext:^(id x) {
        NSLog(@"doNext value: %@", x);
    }] then:^RACSignal *{
        return signal22;
    }];
    
    RACSignal* signalExample = [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@[@"1",@"2",@"3"]];
        [subscriber sendCompleted];
        
        // to test catchTO, we can return another example.
        //        [subscriber sendError:nil];
        
        return nil;
    }] deliverOn:[RACScheduler scheduler]] subscribeOn:[RACScheduler mainThreadScheduler]];
    
    //deliverOn calculate Signal on given scheduler or thread.
    
    //subscribeOn: handle side effects and subscribe blocks on given thread.
    
    //catch errors and return Signal
    signalExample = [signalExample catchTo:[RACSignal return:@[]]];
    
    // relative to error, ve can
    //    [signalExample catch:^RACSignal *(NSError *error) {
    //
    //    }]
    
    signalExample = [signalExample initially:^{
        NSLog(@"initially");
    }];
    
    signalExample = [signalExample doCompleted:^{
        // do some side effect after
        NSLog(@"doCompleted");
    }];
    
    signalExample = [signalExample doNext:^(id x) {
        // some side effect here
        NSLog(@"doNext value: %@", x);
    }];
    
    signalExample = [signalExample doError:^(NSError *error) {
        // handle error
    }];
    
    [signalExample subscribeNext:^(id x) {
        NSLog(@"subscribeNext signal11 %@",x);
    }];
    
    //    RACDisposable *disposable = [signalExample subscribeNext:^(id x) {
    //        NSLog(@"subscribeNext signal11 %@",x);
    //    }];
    //    [disposable dispose];
    
    
    RACSequence *lettersSequence = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence;
    RACSequence *numbersSequence = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;
    // Contains: A B C D E F G H I 1 2 3 4 5 6 7 8 9
    RACSequence *concatenated = [lettersSequence concat:numbersSequence];
    NSLog(@"%@",concatenated.array);
    
    // Contains: 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9
    RACSequence *extended = [numbersSequence flattenMap:^(NSString *numberString) {
        return @[numberString, numberString].rac_sequence;
    }];
    NSLog(@"%@",extended.array);
    
    
    RACSignal *lettersSignal = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence.signal;
    // The new signal only contains: 1 2 3 4 5 6 7 8 9
    //
    // But when subscribed to, it also outputs: A B C D E F G H I
    RACSignal *sequenced = [[lettersSignal
                             doNext:^(NSString *letter) {
                                 NSLog(@"letter === %@", letter);
                                 // called first
                                 // for every letter in array
                             }]
                            then:^{
                                NSLog(@"then called ===");
                                // called second
                                RACSignal* signalExample = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                                    [subscriber sendNext:@"Hello signalExample"];
                                    [subscriber sendCompleted];
                                    return nil;
                                }];
                                return signalExample;
                            }];
    
    [sequenced subscribeNext:^(NSString *word){
        // called last, puts = Hello signalExample
        NSLog(@"=== word = %@",word);
    }];
    
    //
    // Combine two methods in RACStream, it returns RACStream
    //
    NSArray *words = @[@"werewrwr",@"werewrewrewrewr",@"werwerewrewrewrewrewrewrewr",@"wt234324234324"];
    RACSequence *normalizedLongWords = [[words.rac_sequence
                                         filter:^ BOOL (NSString *word) {
                                             return [word length] >= 10;
                                         }]
                                        map:^(NSString *word) {
                                            return [word lowercaseString];
                                        }];
    NSLog(@"FILTER AND MAP combined %@",normalizedLongWords.array);
    
    
    //
    // "WHERE" method in RACStream, filter retutns
    //
    NSArray *filteredArray = [[words.rac_sequence filter:^ BOOL (NSString *word) {
        return [word length] >= 20;
    }] array];
    NSLog(@"FILTERED %@",filteredArray);
    
    //
    // "SELECT" method in RACStream, filter retutns
    //
    NSArray *mappedArray = [[words.rac_sequence map:^(NSString *word) {
        return [word lowercaseString];
    }] array];
    
    NSLog(@"MAPPED %@",mappedArray);
    
    // if one of signal returns YES, return YES
    BOOL isAnyWordLenght = [words.rac_sequence any:^BOOL(id value) {
        
        if (words.count > 0) {
            return YES;
        }else {
            return NO;
        }
        
    }];
    
    NSLog(@"isAnyWordLenght = %@",@(isAnyWordLenght));
    
    // all should be YES
    BOOL isAllWordLenght = [words.rac_sequence all:^BOOL(id value) {
        
        if (words.count > 20) {
            return YES;
        }else {
            return NO;
        }
        
    }];
    
    NSLog(@"isAllWordLenght = %@",@(isAllWordLenght));
    
    // ???
    //    [words.rac_sequence reduceEach:^id{
    //        return nil;
    //    }];
    
    NSLog(@"HEAD %@", [words.rac_sequence head]);
    NSLog(@"TAIL HEAD %@", [words.rac_sequence.tail head]);
    
    
    //    words.rac_sequence.lazySequence;
    //    words.rac_sequence.eagerSequence;
    
    
    //    self.username = @"User";
    //
    //    //RACScheduler
    //    [[RACObserve(self, username)
    //      filter:^(NSString *newName) {
    //          return [newName hasPrefix:@"j"];
    //      }]
    //     subscribeNext:^(NSString *newName) {
    //         NSLog(@"%@", newName);
    //     }];
    
    
    //This would send @YES every time self.recording's
    //value changes to YES, and ignore any NOs:
    //RACSignal *mySignal = [RACObserve(self, recording) ignore:@NO];
    
    //This would skip the initial value, regardless of whether it's NO or YES,
    //and would send every subsequent value (either NO or YES):
    //RACSignal *mySignal = [RACObserve(self, recording) skip:1];
    
    
    [[[RACObserve(self, username) ignore:nil] doNext:^(NSString *newUsername){
        NSLog(@"doNext %@", newUsername);
    }] subscribeNext:^(id x) {
        NSLog(@"subscribeNext %@", x);
    } error:^(NSError *error){
        NSLog(@"ERROR = %@",error);
    }];
    
    self.username = @"userName1";
    
    //    self.username = @"userName2";
    //    [[RACObserve(self, username) doNext:^(id x) {
    //        NSLog(@" _1_  %@",x);
    //    }] doNext:^(id x) {
    //        NSLog(@" _2_  %@",x);
    //    }];
    
    
    //    self.username = @"userName3";
    //    //
    //    //
    //    [[RACObserve(self, username)
    //      filter:^(NSString *newName) {
    //          return [newName hasPrefix:@"j"];
    //      }]
    //     subscribeNext:^(NSString *newName) {
    //         NSLog(@"%@", newName);
    //     }];
    
    
    
    // ????
    //foldLeftWithStart
    //combineLatest
    
    NSArray *signalsArray = @[[RACObserve(self, password) ignore:nil], [RACObserve(self, passwordConfirmation) ignore:nil]];
    RACSignal *someSignal = [RACSignal combineLatest:signalsArray
                                              reduce:^(NSString *password, NSString *passwordConfirm) {
                                                  
                                                  NSLog(@"password = %@",password);
                                                  NSLog(@"password = %@",passwordConfirm);
                                                  
                                                  return @([passwordConfirm isEqualToString:password]);
                                              }];
    [someSignal subscribeNext:^(NSNumber *boolNumber) {
        NSLog(@"%@", boolNumber);
    }];
    
    self.password = @"pass1";
    self.passwordConfirmation = @"pass1";
    
    
    RACSignal *someSignalFirstForToken = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // here we get token
        [subscriber sendNext:@"token_string"];
        return nil;
    }];
    
    RACSignal *flattenMapSignal = [someSignalFirstForToken flattenMap:^RACStream *(NSString *token) {
        return  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            // here we get token
            [subscriber sendNext:[NSString stringWithFormat:@"token+token+%@",token]];
            return nil;
        }];
    }];
    
    [flattenMapSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    
    // Good examples of "flattenMap"
    [[[[RACObserve(self, flattenTestString) ignore:nil] flattenMap:^RACStream *(NSString *newFlattenString) {
        NSArray *newPassArray = @[newFlattenString];
        
        RACSequence *lowerCaseSequence = [[newPassArray rac_sequence] map:^id(NSString *newPassword) {
            return [newPassword lowercaseString];
        }];
        
        return lowerCaseSequence.signal;
    }] flattenMap:^RACStream *(NSString *lowerCasedString) {
        
        NSArray *lowerCasedStringArray = @[lowerCasedString];
        
        RACSequence *uperCaseSequence = [[lowerCasedStringArray rac_sequence] map:^id(NSString *newPassword) {
            return [newPassword uppercaseString];
        }];
        
        return uperCaseSequence.signal;
    }] subscribeNext:^(id x) {
        NSLog(@"UPPERCASED = %@",x);
    }];
    
    self.flattenTestString = @"dsfdfsdf_sdfdsf_sdfsdfsdf";
    
    __block NSUInteger countIndex = 0;
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
        countIndex ++;
        [subscriber sendNext:@(1)];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(2)];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [signal1 subscribeNext:^(id x) {
        NSLog(@"countIndex = %@ ||| sendedNext = %@", @(countIndex), x);
    }];
    [signal1 subscribeNext:^(id x) {
        NSLog(@"countIndex = %@ ||| sendedNext = %@", @(countIndex), x);
    }];
    [signal1 subscribeNext:^(id x) {
        NSLog(@"countIndex = %@ ||| sendedNext = %@", @(countIndex), x);
    }];
    
    RACSignal *combinedSignal = [RACSignal combineLatest:@[signal1, signal2]];
    [combinedSignal subscribeNext:^(RACTuple *tuple) {
        RACTupleUnpack(NSNumber *n1, NSNumber *n2) = tuple;
        NSLog(@"n1 = %@  n2 = %@",n1,n2);
    }];
    
    
    RACSignal *mergedSignal = [RACSignal merge:@[signal1, signal2]];
    [mergedSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    RACSignal *throttleSignal = [RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(100)];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *throttle2Signal = [RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(100)];
        [subscriber sendCompleted];
        return nil;
    }];

    RACSignal *throttleMergedSignal = [RACSignal merge:@[throttleSignal, throttle2Signal]];
    
    [[throttleMergedSignal throttle:3] subscribeNext:^(NSNumber *numberValue) {
        NSLog(@"numberValue = %@",numberValue);
    }];
    
    [[throttleMergedSignal delay:3] subscribeNext:^(NSNumber *numberValue) {
        NSLog(@"numberValue = %@",numberValue);
    }];

    [[throttleMergedSignal take:2] subscribeNext:^(NSNumber *numberValue) {
        NSLog(@"numberValue = %@",numberValue);
    }];
    
    RACReplaySubject *subjectTest = [RACReplaySubject subject];
    [subjectTest sendNext:@(123456789)];
    [subjectTest sendCompleted];
    [subjectTest subscribeNext:^(id x) {
        NSLog(@"subscribeNext = %@",x);
    }];
    
    
    
    
    //    RACSignal *mergedSignal = [[RACSignal merge:@[signal1, signal2]] subscribeCompl:^(){
    //        NSLog(@"Completed!!!");
    //    }];
    
    // simple Examples
    //http://www.slideshare.net/jarsen7/learn-you-a-reactive-cocoa-for-great-good
    
    
    NSArray *numbers = @[@(1),@(2),@(3),@(4),@(5)];
    NSNumber *startPosition = @(100);
    NSNumber *totalSum = [numbers.rac_sequence foldLeftWithStart:startPosition reduce:^id(id accumulator, id objectOfArray) {
        return @([accumulator integerValue] + [objectOfArray integerValue]);
    }];
    
    NSLog(@"totalSum = %@",totalSum);
    
    
    //    [[[[client
    //        logInUser]
    //       flattenMap:^(User *user) {
    //           // Return a signal that loads cached messages for the user.
    //           return [client loadCachedMessagesForUser:user];
    //       }]
    //      flattenMap:^(NSArray *messages) {
    //          // Return a signal that fetches any remaining messages.
    //          return [client fetchMessagesAfterMessage:messages.lastObject];
    //      }]
    //     subscribeNext:^(NSArray *newMessages) {
    //         NSLog(@"New messages: %@", newMessages);
    //     } completed:^{
    //         NSLog(@"Fetched all messages.");
    //     }];
    
    
    //    RACSignal *formValid = [RACSignal
    //                            combineLatest:@[
    //                                            self.firstNameField.rac_textSignal,
    //                                            self.lastNameField.rac_textSignal,
    //                                            self.emailNameField.rac_textSignal
    //                                            ]
    //                            reduce:^(NSString *firstName, NSString *lastName, NSString *email) {
    //                                return @(firstName.length > 0 && lastName.length > 0 && email.length > 0);
    //                            }];
    //
    //    RAC(self, createButton.enabled)= formValid;
    //
    //    // ??? Do not understand this
    //    RACSignal *executing = nil;
    //    RACSignal *fieldTextColor = [executing map:^(NSNumber *x) {
    //        return x.boolValue ? UIColor.lightGrayColor : UIColor.blackColor;
    //    }];
    //
    //    RAC(self, firstNameField.textColor) = fieldTextColor;
    //    RAC(self, lastNameField.textColor) = fieldTextColor;
    //    RAC(self, emailNameField.textColor) = fieldTextColor;
    //
    //
    //    RACSignal *notProcessing = [executing map:^(NSNumber *x) {
    //        return @(!x.boolValue);
    //    }];
    //
    //    RAC(self, firstNameField.enabled) = notProcessing;
    //    RAC(self, lastNameField.enabled) = notProcessing;
    //    RAC(self, emailNameField.enabled) = notProcessing;
    
    
    //Parallelizing independent work on background thread
    RACSignal *databaseSignal = [RACSignal startEagerlyWithScheduler:[RACScheduler scheduler] block:^(id<RACSubscriber> subscriber) {
        NSMutableArray *databaseDatas = [NSMutableArray arrayWithObjects:@"1",@"2",@"3", nil];
        [subscriber sendNext:[databaseDatas copy]];
        [subscriber sendCompleted];
    }];
    
    RACSignal *fileSignal = [RACSignal startEagerlyWithScheduler:[RACScheduler scheduler] block:^(id<RACSubscriber> subscriber) {
        NSMutableArray *fileDatas = [NSMutableArray arrayWithObjects:@"A",@"B",@"C", nil];
        [subscriber sendNext:[fileDatas copy]];
        [subscriber sendCompleted];
    }];
    
    RACSignal *combineSignal = [RACSignal
                                combineLatest:@[ databaseSignal, fileSignal ]
                                reduce:^ id (NSArray *databaseDatas, NSArray *fileDatas) {
                                    NSMutableArray *allObjects = [NSMutableArray new];
                                    [allObjects addObjectsFromArray:databaseDatas];
                                    [allObjects addObjectsFromArray:fileDatas];
                                    return [[NSArray alloc] initWithArray:allObjects];
                                }];
    [[combineSignal deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSArray *allObjects){
         NSLog(@"%@",allObjects);
     }];
    
    
    RACSubject *frameSubject = [RACSubject subject];
    
    RACSignal *frameChanged = [[frameSubject distinctUntilChanged] startWith:@(0)];
    [frameChanged subscribeNext:^(NSNumber *number){
        NSLog(@"number = %@",number);
    }];
    [frameSubject sendNext:@(1000)];
    
    
    
    RACSubject *subject = [[RACSubject subject] startWith:@"foo"];
    [subject subscribeNext:^(id x) {
        NSLog(@"FOO IS = %@",x);
    }];
    
    RACSubject *subject2 = [RACSubject subject];
    RACSignal *signal222 = [subject2 startWith:@"BAR"];
    [signal222 subscribeNext:^(id x) {
        NSLog(@"FOO IS = %@",x);
    }];
    
    
    
    //http://spin.atomicobject.com/2014/04/03/combinelatest-and-zip-in-reactivecocoa/
    RACSubject *lettersSubject = [RACSubject subject];
    RACSubject *numbersSubject = [RACSubject subject];
    
    RACSignal *combined = [RACSignal
                           combineLatest:@[lettersSubject , numbersSubject]
                           reduce:^(NSString *letter, NSString *number) {
                               return [letter stringByAppendingString:number];
                           }];
    
    // Outputs: B1 B2 C2 C3 D3 D4
    [combined subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    
    [lettersSubject sendNext:@"A"];
    [lettersSubject sendNext:@"B"];
    
    [numbersSubject sendNext:@"1"];
    [numbersSubject sendNext:@"2"];
    
    [lettersSubject sendNext:@"C"];
    
    [numbersSubject sendNext:@"3"];
    
    [lettersSubject sendNext:@"D"];
    
    [numbersSubject sendNext:@"4"];
    
    
    
    
    [[[[RACObserve(self, testString)
        distinctUntilChanged]
       take:3]
      filter:^(NSString *newUsername) {
          return YES;
      }]
     subscribeNext:^(NSString *finalString) {
         NSLog(@"Hi me is = %@",finalString);
         
         // log results:
         //Hi me is = (null)
         //Hi me is = 1
         //Hi me is = 2
         
         
     }];
    
    self.testString = @"1";
    self.testString = @"2";
    self.testString = @"3";
    self.testString = @"4";
    self.testString = @"5";
    
    
    /*
     * whenever `model property of our ViewModel object, or model's date property,
     * changes - dateString is automatically populated with corresponding value.
     */
    
    //    @property (nonatomic) NSString *dateString;
    //    @property (nonatomic) Model *model;
    //    ...
    //    RAC(self, dateString) = [RACObserve(self, model.date) map:^id (NSDate *date) {
    //        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //        
    //        return [dateFormatter stringFromDate:date];
    //    }];
    
}


@end

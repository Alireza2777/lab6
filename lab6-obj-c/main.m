//
//  main.m
//  lab6-obj-c
//
//  Created by Alireza Karimi on 2023-09-12.
//helped by chatgbt



#import <Foundation/Foundation.h>

// Dice Class
@interface Dice : NSObject
@property (nonatomic) NSInteger faceValue;
- (void)roll;
@end

@implementation Dice
- (void)roll {
    self.faceValue = arc4random_uniform(6) + 1;
}
@end

// GameController Class
@interface GameController : NSObject
@property (nonatomic, strong) NSMutableArray<Dice *> *diceArray;
@property (nonatomic, strong) NSMutableSet<Dice *> *heldDice;
@property (nonatomic) NSInteger rollsSinceLastReset;

- (instancetype)init;
- (void)rollDice;
- (void)holdDie:(NSInteger)index;
- (void)unholdDie:(NSInteger)index;
- (void)resetDice;
- (NSInteger)calculateScore;
- (void)displayDice;
@end

@implementation GameController
- (instancetype)init {
    self = [super init];
    if (self) {
        _diceArray = [NSMutableArray arrayWithCapacity:5];
        _heldDice = [NSMutableSet set];
        _rollsSinceLastReset = 0;

        // Initialize and add five dice objects to the array
        for (NSInteger i = 0; i < 5; i++) {
            Dice *dice = [[Dice alloc] init];
            [dice roll];
            [_diceArray addObject:dice];
        }
    }
    return self;
}

- (void)rollDice {
    for (Dice *dice in self.diceArray) {
        [dice roll];
    }
    self.rollsSinceLastReset++;
}

- (void)holdDie:(NSInteger)index {
    if (index >= 0 && index < self.diceArray.count) {
        Dice *selectedDice = self.diceArray[index];
        [self.heldDice addObject:selectedDice];
    }
}

- (void)unholdDie:(NSInteger)index {
    if (index >= 0 && index < self.diceArray.count) {
        Dice *selectedDice = self.diceArray[index];
        [self.heldDice removeObject:selectedDice];
    }
}

- (void)resetDice {
    [self.heldDice removeAllObjects];
    self.rollsSinceLastReset = 0;
}

- (NSInteger)calculateScore {
    NSInteger score = 0;
    for (Dice *dice in self.heldDice) {
        if (dice.faceValue != 3) {
            score += dice.faceValue;
        }
    }
    return score;
}

- (void)displayDice {
    NSMutableString *output = [NSMutableString stringWithString:@"Dice: "];
    for (Dice *dice in self.diceArray) {
        if ([self.heldDice containsObject:dice]) {
            [output appendFormat:@"[%ld] ", (long)dice.faceValue];
        } else {
            [output appendFormat:@"%ld ", (long)dice.faceValue];
        }
    }
    [output appendFormat:@"| Score: %ld | Rolls: %ld", (long)[self calculateScore], (long)self.rollsSinceLastReset];
    NSLog(@"%@", output);
}
@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        GameController *gameController = [[GameController alloc] init];

        while (1) {
            [gameController displayDice];

            NSLog(@"\nEnter a command (roll, hold, unhold, reset, quit):");
            char input[255];
            fgets(input, sizeof(input), stdin);
            NSString *command = [NSString stringWithUTF8String:input];
            command = [command stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            if ([command isEqualToString:@"roll"]) {
                [gameController rollDice];
            } else if ([command isEqualToString:@"hold"]) {
                NSLog(@"Enter the index of the die to hold:");
                char indexInput[255];
                fgets(indexInput, sizeof(indexInput), stdin);
                NSInteger index = [[NSString stringWithUTF8String:indexInput] integerValue];
                [gameController holdDie:index];
            } else if ([command isEqualToString:@"unhold"]) {
                NSLog(@"Enter the index of the die to unhold:");
                char indexInput[255];
                fgets(indexInput, sizeof(indexInput), stdin);
                NSInteger index = [[NSString stringWithUTF8String:indexInput] integerValue];
                [gameController unholdDie:index];
            } else if ([command isEqualToString:@"reset"]) {
                [gameController resetDice];
            } else if ([command isEqualToString:@"quit"]) {
                break;
            }
        }
    }
    return 0;
}


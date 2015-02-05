//
//  Penguin.m
//  PeevedPenguins
//
//  Created by Jiayu Liu on 1/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Penguin.h"

@implementation Penguin

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"penguin";
}

@end

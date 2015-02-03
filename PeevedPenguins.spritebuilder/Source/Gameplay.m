//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Jiayu Liu on 1/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay
{
    CCPhysicsNode *_physicsNode;
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_catapultArm;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    CCNode *_currentPenguin;
    CCPhysicsJoint *_penguinCatapultJoint;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];

    _physicsNode.debugDraw = YES;
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];

    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
}

// called on every touch in this scene
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_contentNode];

    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation)) {
        _mouseJointNode.position = touchLocation;
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody
                                                              bodyB:_catapultArm.physicsBody
                                                            anchorA:ccp(0.0, 0.0)
                                                            anchorB:ccp(34.0, 138.0)
                                                         restLength:0.0f
                                                          stiffness:3000.0f
                                                            damping:150.f];

        // create a penguin from the ccb-file
        _currentPenguin = [CCBReader load:@"Penguin"];
        // initially position it on the scoop. 34,138 is the position in the node space of the _catapultArm
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34, 138)];
        // transform the world position to the node space to which the penguin will be added (_physicsNode)
        _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
        // add it to the physics world
        [_physicsNode addChild:_currentPenguin];
        // we don't want the penguin to rotate in the scoop
        _currentPenguin.physicsBody.allowsRotation = FALSE;
        // create a joint to keep the penguin fixed to the scoop until the catapult is released
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody
                                                                       bodyB:_catapultArm.physicsBody
                                                                     anchorA:_currentPenguin.anchorPointInPoints];
    }
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    [self releaseCatapult];
}

- (void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    [self releaseCatapult];
}

- (void)releaseCatapult {
    if (_mouseJointNode != nil) {
        [_mouseJoint invalidate];
        _mouseJoint = nil;
        // releases the joint and lets the penguin fly
        [_penguinCatapultJoint invalidate];
        _penguinCatapultJoint = nil;
        // after snapping rotation is fine
        _currentPenguin.physicsBody.allowsRotation = TRUE;
        // follow the flying penguin
        CCActionFollow *follow = [CCActionFollow actionWithTarget:_currentPenguin
                                                    worldBoundary:self.boundingBox];
        [_contentNode runAction:follow];
    }
}

- (void)launchPenguin {
    // loads the Penguin.ccb we have set up in Spritebuilder
    CCNode* penguin = [CCBReader load:@"Penguin"];
    // position the penguin at the bowl of the catapult
    penguin.position = ccpAdd(_catapultArm.position, ccp(16, 50));

    // add the penguin to the physicsNode of this scene (because it has physics enabled)
    [_physicsNode addChild:penguin];

    // manually create & apply a force to launch the penguin
    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];

    self.position = ccp(0, 0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
}

- (void)retry {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"Gameplay"]];
}


@end

//
//  GameLayer.m
//  Evolution
//
//  Created by Richard Adem on 26/08/12.
//
//

#import "GameLayer.h"
#import "GameConfig.h"
#import "Fish.h"
#import "Man.h"
#import "Water.h"
#import "Score.h"

@interface GameLayer()
@property (nonatomic, retain) NSMutableArray *fishes;
@property (nonatomic, retain) NSMutableArray *men;
@property (nonatomic, retain) Score *score;
@end

@implementation GameLayer

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
    self = [super init];
	if (self)
    {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        WIDTH = winSize.width;
        HEIGHT = winSize.height;
        self.isTouchEnabled = YES;
        
        [self schedule:@selector(update:)];
        
        CCLayerColor *layerColour = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
        [self addChild:layerColour];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"On the Origin the Species the Game" fontName:@"Helvetica" fontSize:24];
		title.position = ccp(WIDTH /2 , HEIGHT - 70.0);
        title.color = (ccColor3B){64, 64, 64};
		[self addChild: title];
        
        CCMoveTo *moveTitle = [CCMoveTo actionWithDuration:2.0 position:ccp(WIDTH /2 , HEIGHT + 70.0)];
        CCDelayTime *delayTitle = [CCDelayTime actionWithDuration:4.0];
        
        [title runAction:[CCSequence actions: delayTitle, moveTitle,  nil]];
        
        const int fishCount = 10;
        self.fishes = [NSMutableArray arrayWithCapacity:fishCount];
        for (int i = 0; i < fishCount; ++i)
        {
            [self makeAFish];
        }
        
        const int menCount = 2;
        self.men = [NSMutableArray arrayWithCapacity:menCount];
        for (int i = 0; i < menCount; ++i)
        {
            [self makeAMan];
        }
        
        Water *water = [Water node];
        [self addChild:water];
        
        self.score = [Score node];
        self.score.position = ccp(WIDTH /2 , HEIGHT + 20.0);
        
        CCDelayTime *delayScore = [CCDelayTime actionWithDuration:5.0];
        CCMoveTo *moveScore0 = [CCMoveTo actionWithDuration:0.5 position:ccp(WIDTH /2 , HEIGHT - 25.0)];
        CCMoveTo *moveScore1 = [CCMoveTo actionWithDuration:0.2 position:ccp(WIDTH /2 , HEIGHT - 20.0)];
        
        [self.score runAction:[CCSequence actions:delayScore,moveScore0, moveScore1, nil]];
        [self addChild:self.score];
    }
    return self;
}

- (void) update:(ccTime) deltaTime
{
    for (Fish *f in self.fishes)
    {
        if (f.fresh)
        {
            CGFloat addTo = deltaTime * f.speed;
            if (f.position.x + addTo >= WIDTH + 50)
            {
                //[f setPosition:ccp(- f.textureRect.size.width + addTo, f.position.y)];
                [f setUp];
            }
            else
            {
                [f setPosition:ccp(f.position.x + addTo, f.position.y)];
            }
        }
    }
    
    for (Man *man in self.men)
    {
        if (man.lost)
        {
            CGFloat addTo = deltaTime * man.speed;
            if (man.position.x + addTo >= WIDTH + 100)
            {
                //[man setPosition:ccp(- 100 + addTo, man.position.y)];
                [man setUp];
            }
            else
            {
                [man setPosition:ccp(man.position.x + addTo, man.position.y)];
            }
        }
    }
}

CGPoint startSwipePosition;
Fish *selectedFish;
NSDate *touchDownDate;
- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchDownDate = [[NSDate date] retain];
    UITouch* touch = [touches anyObject];
    startSwipePosition = [touch locationInView: [touch view]];
    startSwipePosition = [[CCDirector sharedDirector] convertToGL:startSwipePosition]; 
    selectedFish = nil;
    for (Fish *fish in self.fishes)
    {
        CGRect fishBB = CGRectMake(fish.position.x - 25
                                   , fish.position.y - 25
                                   , 50
                                   , 50);
        if (CGRectContainsPoint(fishBB, startSwipePosition))
        {
            //[fish setVisible:NO];
            selectedFish = fish;
        }

    }
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    UITouch* touch = [touches anyObject];
//    CGPoint endSwipePosition = [touch locationInView: [touch view]];
    
    float touchTime = [[NSDate date] timeIntervalSinceDate:touchDownDate];
    NSLog(@"touchTime: %.02f", touchTime);
    
    float power = MAX(MIN(touchTime * 10, 1.0), 0.2);
    
    if (selectedFish)
    {
        [selectedFish fireFish:power];
    }
    
    [touchDownDate release];
}


- (void) makeAFish
{
    Fish *f = [Fish node];

    //[f setScale:0.5];
    [f setUp];
    [f setDelegate:self];
    [self addChild:f];
    
    [self.fishes addObject:f];
}

- (void) makeAMan
{
    Man *man = [Man node];
    [man setUp];
    [self addChild:man];
    [self.men addObject:man];
}

- (void) playBigText:(NSString*) text
{
    __block CCLabelTTF *title = [CCLabelTTF labelWithString:text fontName:@"Helvetica-Bold" fontSize:70];
    title.position = ccp(WIDTH /2 , HEIGHT / 2);
    title.color = (ccColor3B){246, 137, 48};
    [self addChild: title];
    
    [title setScale:0.25];
    
    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.5 scale:1.0];
    CCScaleTo *scaleDown = [CCScaleTo actionWithDuration:0.2 scale:0.8];
    
    CCCallBlock *actionRemoveSelf = [CCCallBlock actionWithBlock:^{
        [title removeFromParentAndCleanup:YES];
    }];
    
    [title runAction:[CCSequence actions:scaleUp, scaleDown, actionRemoveSelf, nil]];
    
}

#pragma mark - fish delegate

- (void) fishDidLand:(Fish *)fish
{
    BOOL hit = NO;
    for (Man *man in self.men)
    {
        CGRect manBB = CGRectMake(man.position.x - 50
                                  , man.position.y
                                  , 100
                                  , 50);
        CGRect fishBB = CGRectMake(fish.position.x - 25
                                   , fish.position.y - 25
                                   , 50
                                   , 50);
        if(CGRectIntersectsRect(manBB, fishBB))
        {
            hit = YES;
            [man addedHead];
            [self playBigText:@"+EVOLUTION!"];
            [self.score addToEveloutions];
            [fish setUp];
            break;
        }
    }
    
    if (!hit)
    {
        [fish explode];
    }
    
    
}

#pragma mark - memory man

- (void) dealloc
{
    [_fishes release];
    [_score release];
    [super dealloc];
}

@end

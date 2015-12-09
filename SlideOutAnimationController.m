//
//  SlideOutAnimationController.m
//  FengShui
//
//  Created by ANH TU on 12/9/15.
//  Copyright © 2015 Netvis. All rights reserved.
//

#define SLIDE_TIMING .25

#define AREA_CAN_EXPAND  50

#import "SlideOutAnimationController.h"

@interface SlideOutAnimationController()
{
  /// view has gesture recognizer
  UIView * _superView;
  
  /// view has animation
  UIView * _animationView;
 
  /// the animation view is showing
  BOOL     _isShowing;
  
  ///
  CGSize   _sizeOfSuperView;
  
  ///
  CGSize   _sizeOfAnimationView;
  
  ///
  CGPoint  _preVelocity;
  
  ///
  BOOL     _isSlideFromLeftSide;
}

@end

@implementation SlideOutAnimationController

-(void)moveAnimationViewLeft {
  //  NSLog(@"movePanelLeft");
  [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
    _animationView.frame = CGRectMake(_sizeOfSuperView.width - _sizeOfAnimationView.width, 0,
                                _sizeOfAnimationView.width, _sizeOfAnimationView.height);
  } completion:^(BOOL finished) {}];
  
	[self showCenterViewWithShadow:YES withOffset:-2];
  
  if ([__delegate respondsToSelector:@selector(animationExpandedCallback:)]) {
    [__delegate animationExpandedCallback:YES];
  }
}

-(void)moveAnimationViewToOriginalPosition {
//  NSLog(@"movePanelToOriginalPosition");
  [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
    _animationView.frame = CGRectMake(_sizeOfSuperView.width, 0, _sizeOfAnimationView.width, _sizeOfAnimationView.height);
  } completion:^(BOOL finished) {
    if (finished) {
      [self resetAnimationView];
    }
  }];
  
  if ([__delegate respondsToSelector:@selector(animationExpandedCallback:)]) {
    [__delegate animationExpandedCallback:NO];
  }
}

-(void)resetAnimationView {
  // remove view shadows
  [self showCenterViewWithShadow:NO withOffset:0];
}


-(void)showCenterViewWithShadow:(BOOL)hasShadow withOffset:(double)offset {
  if (hasShadow) {
    [_animationView.layer setShadowColor:[UIColor blackColor].CGColor];
    [_animationView.layer setShadowOpacity:0.8];
    [_animationView.layer setShadowOffset:CGSizeMake(offset, offset)];
    [_animationView.layer setShadowRadius:4.0];
    [_animationView.layer setShadowPath:[UIBezierPath bezierPathWithRect:_animationView.bounds].CGPath];
    
  } else {
    [_animationView.layer setShadowOffset:CGSizeMake(offset, offset)];
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/*!
 * @brief  get min x of animation view's center can have
 */
- (float)getMinCenterX
{
  return _sizeOfSuperView.width - _sizeOfAnimationView.width/2;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/*!
 * @brief  get max x of animation view's center can have
 */
- (float)getMaxCenterX
{
  return _sizeOfSuperView.width + _sizeOfAnimationView.width/2;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/*!
 * @brief   adjust position of animation view from [minX,maxX]
 */
- (void)fixCenterOfAnimation {
  if (_animationView.center.x < [self getMinCenterX]) {
    _animationView.center = CGPointMake([self getMinCenterX],
                                        _animationView.center.y);
  }
  else if (_animationView.center.x > [self getMaxCenterX]) {
    _animationView.center = CGPointMake([self getMaxCenterX],
                                        _animationView.center.y);
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public
////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setupGesturesInView:(UIView *)superView forAnimationOfView:(UIView *)aView
{
  _superView = superView;
  _animationView = aView;
  
  UIPanGestureRecognizer * panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(panGestureCallback:)];
  [panRecognizer setMinimumNumberOfTouches:1];
  [panRecognizer setMaximumNumberOfTouches:1];
  [panRecognizer setDelegate:self];
  [_superView addGestureRecognizer:panRecognizer];
  
  _sizeOfSuperView = _superView.frame.size;
  _sizeOfAnimationView = _animationView.frame.size;
  
	[self showCenterViewWithShadow:YES withOffset:-2];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - gesture callback
////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)panGestureCallback:(id)sender {
  
  [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
  
  CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:_superView];
  CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
  
  if ([(UIPanGestureRecognizer *)sender state] == UIGestureRecognizerStateBegan) {
    CGPoint pointTouched = [(UIPanGestureRecognizer *)sender locationInView:_superView];
    
    /// if the position that is far from right side
    if (velocity.x < 0 && pointTouched.x < _sizeOfSuperView.width - AREA_CAN_EXPAND) {
      _isSlideFromLeftSide = NO;
    }
    else {
      _isSlideFromLeftSide = YES;
    }
  }
  
  /// can't expand with the position that is far from right side
  if (_isSlideFromLeftSide == NO) {
    /* * * * * * * * * * */
    return;
  }
  
  if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
    
    // NSLog(@"gesture went right");
    if(velocity.x > 400) {
      [self moveAnimationViewToOriginalPosition];
    }
    // NSLog(@"gesture went left");
    else if (velocity.x < -400){
        [self moveAnimationViewLeft];
    }
    else if (!_isShowing) {
      [self moveAnimationViewToOriginalPosition];
    }
    else {
        [self moveAnimationViewLeft];
    }
  }
  
  if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
    if(velocity.x > 0) {
      // NSLog(@"gesture went right");
    } else {
      // NSLog(@"gesture went left");
    }
    
    // allow dragging only in x coordinates by only updating the x coordinate with translation position
    _animationView.center = CGPointMake(_animationView.center.x + translatedPoint.x,
                                        _animationView.center.y);
    [self fixCenterOfAnimation];
    [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:_superView];
    
    // are we more than halfway, if so, show the panel when done dragging by setting this value to YES (1)
    if (_sizeOfSuperView.width > _animationView.center.x) {
      _isShowing = YES;
    }
    else {
      _isShowing = NO;
    }
    
    // if you needed to check for a change in direction, you could use this code to do so
    if(velocity.x*_preVelocity.x + velocity.y*_preVelocity.y > 0) {
      // NSLog(@"same direction");
    } else {
      // NSLog(@"opposite direction");
    }
    
    _preVelocity = velocity;
  }
}

@end

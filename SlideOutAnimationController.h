//
//  SlideOutAnimationController.h
//  FengShui
//
//  Created by ANH TU on 12/9/15.
//  Copyright © 2015 Netvis. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SlideOutAnimationDelegate <NSObject>

////////////////////////////////////////////////////////////////////////////////////////////////////
/*!
 * @brief  callback when the view is expanded or collapsed
 *
 * @param  expanded
 */
- (void)animationExpandedCallback:(BOOL)expanded;

@end


@interface SlideOutAnimationController : NSObject <UIGestureRecognizerDelegate>

/// delegate for callback from animation controller
@property (nonatomic, weak) id <SlideOutAnimationDelegate> _delegate;

////////////////////////////////////////////////////////////////////////////////////////////////////
/*!
 * @brief  add animation to a view in a superView
 *
 * @param  superView
 *         superView of animation view
 * @param  aView
 *         animation view
 */
-(void)setupGesturesInView:(UIView *)superView forAnimationOfView:(UIView *)aView;

@end

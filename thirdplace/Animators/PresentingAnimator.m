//
// Created by David Lawson on 17/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "PresentingAnimator.h"


@implementation PresentingAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
    fromView.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    //fromView.userInteractionEnabled = NO;

    UIView *toView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
    toView.center = CGPointMake(transitionContext.containerView.center.x, -transitionContext.containerView.center.y);

    [transitionContext.containerView addSubview:toView];

    POPBasicAnimation *sizeAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBounds];
    sizeAnimation.fromValue = [NSValue valueWithCGRect:fromView.layer.bounds];
    sizeAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 320, 568)];
    [sizeAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [transitionContext completeTransition:YES];
    }];

    [toView.layer pop_addAnimation:sizeAnimation forKey:@"scaleAnimation"];
}

@end
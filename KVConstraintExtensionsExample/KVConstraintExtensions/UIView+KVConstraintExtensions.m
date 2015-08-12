//
//  UIView+KVConstraintExtensions.m
//  KVConstraintExtensionsExample
//
//  Created by Welcome on 04/08/15.
//  Copyright (c) 2015 Keshav. All rights reserved.
//

#import "KVConstraintExtensions.h"

@implementation UIView (KVConstraintExtensions)

#pragma mark - Initializer Methods

+ (instancetype)prepareNewViewForConstraint {
    UIView *preparedView = [self new];
    [preparedView prepareViewForConstraint];
    return preparedView;
}

- (void)prepareViewForConstraint {
    if (self.translatesAutoresizingMaskIntoConstraints) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
}

#pragma mark - private constraint methods for views

+ (NSLayoutConstraint *)prepareConastrainForView:(UIView*)firstView  attribute:(NSLayoutAttribute)attribute1 secondView:(UIView*)secondView attribute:(NSLayoutAttribute)attribute2 relation:(NSLayoutRelation)relation multiplier:(CGFloat)multiplier
{
    NSAssert((firstView||secondView), @"both firstView & secondView must not be nil.");
    NSAssert(multiplier!=INFINITY, @"Multiplier/Ratio of view must not be INFINITY.");
    [firstView prepareViewForConstraint];
    [secondView prepareViewForConstraint];
    
    return [NSLayoutConstraint constraintWithItem:firstView attribute:attribute1 relatedBy:relation toItem:secondView attribute:attribute2 multiplier:multiplier constant:defualtConstant];
}

- (NSLayoutConstraint *)prepareSelfConastrain:(NSLayoutAttribute)attribute constant:(CGFloat)constant
{
    NSLayoutConstraint *prepareSelfConastrain = [self.class prepareConastrainForView:self attribute:attribute secondView:nil attribute:NSLayoutAttributeNotAnAttribute relation:defualtRelation multiplier:defualtMultiplier];
    [prepareSelfConastrain setConstant:constant];
    return prepareSelfConastrain;
}

#pragma mark - Generalized public constraint methods for views

- (NSLayoutConstraint *)prepareConstraintToSuperviewAttribute:(NSLayoutAttribute)attribute1 attribute:(NSLayoutAttribute)attribute2 relation:(NSLayoutRelation)relation
{
    return [self.class prepareConastrainForView:self attribute:attribute1 secondView:[self superview] attribute:attribute2 relation:relation multiplier:defualtMultiplier];
}

- (NSLayoutConstraint *)prepareEqualRelationPinConstraintToSuperview:(NSLayoutAttribute)attribute constant:(CGFloat)constant
{
    NSLayoutConstraint *preparePinConastrain = [self prepareConstraintToSuperviewAttribute:attribute attribute:attribute relation:defualtRelation];
    [preparePinConastrain setConstant:constant];
    return preparePinConastrain;
}

- (NSLayoutConstraint *)prepareEqualRelationPinRatioConstraintToSuperview:(NSLayoutAttribute)attribute multiplier:(CGFloat)multiplier
{
    NSAssert(multiplier!=INFINITY, @"Multiplier/Ratio of view must not be INFINITY.");
    
    // note if ratio is equal to zero then its ratio prefered 1.0 that is defualtMultiplier
    NSLayoutConstraint *preparedPinRatioConastrain = [self.class prepareConastrainForView:self attribute:attribute secondView:[self superview] attribute:attribute relation:defualtRelation multiplier:multiplier?multiplier:defualtMultiplier];
    return preparedPinRatioConastrain;
}

#pragma mark - Prepare constraint of one sibling view to other sibling view and add it into its superview view.

- (NSLayoutConstraint *)prepareConstraintFromSiblingViewAttribute:(NSLayoutAttribute)attribute toAttribute:(NSLayoutAttribute)toAttribute ofView:(UIView *)otherSiblingView relation:(NSLayoutRelation)relation {
    NSMutableSet * set = [NSMutableSet setWithArray:@[self.superview,otherSiblingView.superview]];
    NSAssert((set.count == 1), @"All the sibling views must belong to same superview");
    
    return [self.class prepareConastrainForView:self attribute:attribute secondView:otherSiblingView attribute:toAttribute relation:relation multiplier:defualtMultiplier];
}

- (NSLayoutConstraint *)prepareConstraintFromSiblingViewAttribute:(NSLayoutAttribute)attribute toAttribute:(NSLayoutAttribute)toAttribute ofView:(UIView *)otherSiblingView multiplier:(CGFloat)multiplier {
    NSAssert(multiplier!=INFINITY, @"ratio of spacing between sybings view must not be INFINITY.");
    NSMutableSet * set = [NSMutableSet setWithArray:@[self.superview,otherSiblingView.superview]];
    NSAssert((set.count == 1), @"All the sibling views must belong to same superview");
    
    return [self.class prepareConastrainForView:self attribute:attribute secondView:otherSiblingView attribute:toAttribute relation:defualtRelation multiplier:multiplier];
}

#pragma mark - Add constraints cumulative

/** This is the common methods two add cumulative constraint in a view
 * for this you need to call it according to view (self or Superview)
 */
- (void)applyPreparedConastrainInView:(NSLayoutConstraint *)constraint {
    NSLayoutConstraint *appliedConstraint = [self.constraints containsAppliedConstraint:constraint];
    // if this constraint is already added then it update the constraint values else added new constraint
    if (appliedConstraint) {
        [appliedConstraint setConstant:constraint.constant];
    } else {
        if (constraint) {
            [self addConstraint:constraint];
        }
    }
}

#pragma mark - Modify constraint of a UIView

- (void)changeAppliedConstraintPriorityBy:(UILayoutPriority)priority forAttribute:(NSLayoutAttribute)attribute {
    [[self accessAppliedConstraintByAttribute:attribute] setPriority:priority];
}

- (void)replaceAppliedConastrainInView:(NSLayoutConstraint *)appliedConstraint replaceBy:(NSLayoutConstraint *)constraint {
    NSAssert(constraint!=nil, @" modifiedConstraint must not be nil");
    
    if ([appliedConstraint isEqualToConstraint:constraint]){
        [self removeConstraint:appliedConstraint];
        [self addConstraint:constraint];
    }else{
        NSLog(@"appliedConstraint does not contain caller view = %@ \n appliedConstraint = %@",self,appliedConstraint);
    }
}

#pragma mark - Access Applied Constraint By Attributes From a specific View

- (NSLayoutConstraint*)accessAppliedConstraintByAttribute:(NSLayoutAttribute)attribute {
    return [NSLayoutConstraint appliedConstraintForView:self attribute:attribute];
}

- (void)accessAppliedConstraintByAttribute:(NSLayoutAttribute)attribute completion:(void (^)(NSLayoutConstraint *appliedConstraint))completion
{
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([self accessAppliedConstraintByAttribute:attribute]);
        });
    }
}

#pragma mark - Pin Edges to Superview
// adding or updating the constraint
- (void)applyPreparedEqualRelationPinConstraintToSuperview:(NSLayoutAttribute)attribute constant:(CGFloat)constant {
    NSAssert(self.superview, @"You should have addSubView %@ on any other its called's Superview ", self);
    NSAssert(constant!=INFINITY, @"Constant must not be INFINITY.");
    [self.superview applyPreparedConastrainInView:[self prepareEqualRelationPinConstraintToSuperview:attribute constant:constant]];
}

- (void)applyLeftPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeLeft constant:padding];
}
- (void)applyRightPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeRight constant:-padding];
}
- (void)applyTopPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeTop constant:padding];
}
- (void)applyBottomPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeBottom constant:-padding];
}
- (void)applyLeadingPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeLeading constant:padding];
}
- (void)applyTrailingPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeTrailing constant:-padding];
}
- (void)applyCenterXPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeCenterX constant:padding];
}
- (void)applyCenterYPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeCenterY constant:padding];
}
- (void)applyLeadingAndTrailingPinConstraintToSuperviewWithPadding:(CGFloat)padding{
    [self applyLeadingPinConstraintToSuperviewWithPadding:padding];
    [self applyTrailingPinConstraintToSuperviewWithPadding:padding];
}
- (void)applyTopAndBottomPinConstraintToSuperviewWithPadding:(CGFloat)padding{
    [self applyBottomPinConstraintToSuperviewWithPadding:padding];
    [self applyTopPinConstraintToSuperviewWithPadding:padding];
}
- (void)applyEqualWidthPinConstrainToSuperview {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeWidth constant:defualtConstant];
}
- (void)applyEqualHeightPinConstrainToSuperview {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeHeight constant:defualtConstant];
}

- (void)applyEqualHeightRatioPinConstrainToSuperview:(CGFloat)ratio {
    // first method to get equal Ratio constraint
    NSAssert(self.superview, @" Superview must not be nil.\n For View: %@", self);
    NSAssert(ratio!=INFINITY, @" Ratio must not be INFINITY.");
    
    NSLayoutConstraint *equalHeightRatioPinConstraint = [self prepareEqualRelationPinRatioConstraintToSuperview:NSLayoutAttributeHeight multiplier:ratio];
    if (equalHeightRatioPinConstraint) {
        [self.superview applyPreparedConastrainInView:equalHeightRatioPinConstraint];
    }
}

- (void)applyEqualWidthRatioPinConstrainToSuperview:(CGFloat)ratio {
    // first method to get equal Ratio constraint
    NSAssert(self.superview, @" Superview of this view must not be nil.\n For View: %@", self);
    NSAssert(ratio!=INFINITY, @" Ratio must not be INFINITY.");
    
    NSLayoutConstraint *equalHeightRatioPinConstraint = [self prepareEqualRelationPinRatioConstraintToSuperview:NSLayoutAttributeWidth multiplier:ratio];
    if (equalHeightRatioPinConstraint) {
        [self.superview applyPreparedConastrainInView:equalHeightRatioPinConstraint];
    }
}

/*  Center horizontally and Vertically  */
- (void)applyConstraintForCenterInSuperview {
    [self applyCenterXPinConstraintToSuperviewWithPadding:defualtConstant];
    [self applyCenterYPinConstraintToSuperviewWithPadding:defualtConstant];
}

- (void)applyConstraintForVerticallyCenterInSuperview {
    [self applyCenterYPinConstraintToSuperviewWithPadding:defualtConstant];
}

- (void)applyConstraintForHorizontallyCenterInSuperview {
    [self applyCenterXPinConstraintToSuperviewWithPadding:defualtConstant];
}

- (void)applyConstraintFitToSuperview {
    // First way
    [self applyConstraintFitToSuperviewContentInset:UIEdgeInsetsZero];
    
    // OR Second way to do the same thing
    /* [self applyEqualHeightPinConstrainToSuperview];
     [self applyEqualWidthPinConstrainToSuperview];
     [self applyConstraintForCenterInSuperview];
     */
}

- (void)applyConstraintFitToSuperviewHorizontally{
    [self applyRightPinConstraintToSuperviewWithPadding:defualtConstant];
    [self applyLeftPinConstraintToSuperviewWithPadding:defualtConstant];
}
- (void)applyConstraintFitToSuperviewVertically{
    //    INFINITY/HUGE_VALF is used to exclude the constraint from the view
    [self applyConstraintFitToSuperviewContentInset:UIEdgeInsetsMake(0, INFINITY, 0, HUGE_VALF)];
}

- (void)applyConstraintFitToSuperviewContentInset:(UIEdgeInsets)Insets {
    if (Insets.top!=INFINITY) {
        [self applyTopPinConstraintToSuperviewWithPadding:Insets.top];
    }
    if (Insets.left!=INFINITY) {
        [self applyLeftPinConstraintToSuperviewWithPadding:Insets.left];
    }
    if (Insets.bottom!=INFINITY) {
        [self applyBottomPinConstraintToSuperviewWithPadding:Insets.bottom];
    }
    if (Insets.right!=INFINITY) {
        [self applyRightPinConstraintToSuperviewWithPadding:Insets.right];
    }
}

#pragma mark - Apply self constraints
- (void)applyAspectRatioConstrain {
    [self applyPreparedConastrainInView:[self.class prepareConastrainForView:self attribute:NSLayoutAttributeWidth secondView:self attribute:NSLayoutAttributeHeight relation:defualtRelation multiplier:defualtMultiplier]];
}
- (void)applyWidthConstraint:(CGFloat)width {
    if (width!=INFINITY) {
        [self applyPreparedConastrainInView:[self prepareSelfConastrain:NSLayoutAttributeWidth constant:width]];
    }else {
        NSLog(@"Width of the view con not be INFINITY");
    }
}
- (void)applyHeightConstrain:(CGFloat) height {
    if (height!=INFINITY) {
        [self applyPreparedConastrainInView:[self prepareSelfConastrain:NSLayoutAttributeHeight constant:height]];
    } else {
        NSLog(@"Height of the view con not be INFINITY");
    }
}

#pragma mark - Apply Constraint between sibling views

- (void)applyConstraintFromSiblingViewAttribute:(NSLayoutAttribute)attribute toAttribute:(NSLayoutAttribute)toAttribute ofView:(UIView *)otherSiblingView spacing:(CGFloat)spacing {
    NSAssert(spacing!=INFINITY, @"spacing between sybings view must not be INFINITY.");
    
    NSLayoutConstraint *prepareConstraintForSiblingView =  [self prepareConstraintFromSiblingViewAttribute:attribute toAttribute:toAttribute ofView:otherSiblingView multiplier:defualtMultiplier];
    [prepareConstraintForSiblingView setConstant:spacing];
    
    if ([NSLayoutConstraint recognizedDirectionByAttribute:attribute toAttribute:toAttribute]) {
        [self.superview applyPreparedConastrainInView:[prepareConstraintForSiblingView swapConstraintItems]];
    }else {
        [self.superview applyPreparedConastrainInView:prepareConstraintForSiblingView];
    }
}

#pragma mark - Constraint for LayoutGuide of viewController

- (NSLayoutConstraint *)prepareEqualRelationPinConastrainToTopLayoutGuideOfViewController:(UIViewController *)viewController WithPadding:(CGFloat)padding {
    [self prepareViewForConstraint];
    NSLayoutConstraint *preparedTopLayoutGuideConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:defualtRelation toItem:viewController.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:defualtMultiplier constant:padding];
    [viewController.view applyPreparedConastrainInView:preparedTopLayoutGuideConstraint];
    
    return preparedTopLayoutGuideConstraint;
}

- (NSLayoutConstraint *)prepareEqualRelationPinConastrainToBottomLayoutGuideOfViewController:(UIViewController *)viewController WithPadding:(CGFloat)padding {
    [self prepareViewForConstraint];
    
    NSLayoutConstraint *preparedBottomLayoutGuideConstraint = [NSLayoutConstraint constraintWithItem:viewController.bottomLayoutGuide attribute:NSLayoutAttributeTop relatedBy:defualtRelation toItem:self attribute:NSLayoutAttributeBottom multiplier:defualtMultiplier constant:padding];
    
    [viewController.view applyPreparedConastrainInView:preparedBottomLayoutGuideConstraint];
    
    return preparedBottomLayoutGuideConstraint;
}

@end
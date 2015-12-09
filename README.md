Init
```
_slideAnimationController = [SlideOutAnimationController new];
  [_slideAnimationController setupGesturesInView:superView forAnimationOfView:rightMenuView];
_slideAnimationController._delegate = self;
```

Callback:

`- (void)animationExpandedCallback:(BOOL)expanded`

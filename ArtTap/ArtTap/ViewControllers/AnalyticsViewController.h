//
//  AnalyticsViewController.h
//  ArtTap
//
//  Created by Nancy Wu on 7/12/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Charts;

NS_ASSUME_NONNULL_BEGIN

@interface AnalyticsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *views;
@property (weak, nonatomic) IBOutlet UILabel *likes;
@property (weak, nonatomic) IBOutlet UILabel *engaged;
@property (strong, nonatomic) Post *post;

@end

NS_ASSUME_NONNULL_END

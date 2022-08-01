//
//  HomePhotoCell.m
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import "HomePhotoCell.h"

@implementation HomePhotoCell 

- (void)awakeFromNib {
    [super awakeFromNib];
    UILongPressGestureRecognizer *previewGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(previewPost:)];
    previewGestureRecognizer.minimumPressDuration = 0.5;
    previewGestureRecognizer.delegate = self;
    [self.image addGestureRecognizer:previewGestureRecognizer];
    [self.image setUserInteractionEnabled:YES];
}

- (void) previewPost:(UILongPressGestureRecognizer *)sender{
    NSLog(@"hold gesture triggered");
    [self.delegate didPreview:self.post];
}

@end

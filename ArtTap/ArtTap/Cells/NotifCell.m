//
//  NotifCell.m
//  ArtTap
//
//  Created by Nancy Wu on 7/13/22.
//

#import "NotifCell.h"

@implementation NotifCell
- (IBAction)triggeredSegue:(id)sender {
    [self.delegate didTapNotif:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

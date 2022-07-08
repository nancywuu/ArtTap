//
//  HomeFeedLayout.h
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol HomeFeedLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface HomeFeedLayout : UICollectionViewLayout
@property (nonatomic, weak) id<HomeFeedLayoutDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

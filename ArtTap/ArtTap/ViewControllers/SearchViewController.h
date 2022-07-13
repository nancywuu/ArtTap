//
//  SearchViewController.h
//  ArtTap
//
//  Created by Nancy Wu on 7/12/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;

@end

NS_ASSUME_NONNULL_END

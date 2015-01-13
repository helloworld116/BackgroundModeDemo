//
//  DetailViewController.h
//  BackgroundModeDemo
//
//  Created by sdzg on 15-1-13.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end


//
//  AGXAlbumPickerController.m
//  AGXWidget
//
//  Created by Char Aznable on 2018/1/17.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  banchichen/TZImagePickerController
//

//  The MIT License (MIT)
//
//  Copyright (c) 2016 Zhen Tan
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/AGXMath.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSAttributedString+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>
#import "AGXAlbumPickerController.h"
#import "AGXWidgetLocalization.h"
#import "AGXLine.h"
#import "AGXProgressHUD.h"
#import "AGXPhotoManager.h"

AGX_STATIC NSString *const AGXAlbumCellReuseIdentifier = @"AGXAlbumCellReuseIdentifier";

AGX_STATIC const CGFloat AGXAlbumCellHeight = 68;
AGX_STATIC const CGSize  AGXAlbumCellCoverImageSize = (CGSize){.width = 60, .height = 60};
AGX_STATIC const CGFloat AGXAlbumCellAccessoryMargin = 36;

@interface AGXAlbumTableViewCell : UITableViewCell
@property (nonatomic, AGX_STRONG) AGXAlbumModel *albumModel;
@end

@interface AGXAlbumPickerController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, AGX_STRONG) NSArray<AGXAlbumModel *> *albumModels;
@end

@implementation AGXAlbumPickerController {
    UITableView *_tableView;
}

@dynamic delegate;

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if AGX_EXPECT_T(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = AGXWidgetLocalizedStringDefault
        (@"AGXPhotoPickerController.albumTitle", @"Photos");

        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = [UIView viewWithFrame:CGRectMake(0, 0, 0, AGX_SinglePixel)];
        _tableView.tableHeaderView.backgroundColor = UIColor.lightGrayColor;
        _tableView.tableFooterView = [UIView viewWithFrame:CGRectMake(0, 0, 0, AGXAlbumCellHeight)];
        _tableView.tableFooterView.backgroundColor = UIColor.whiteColor;
        [_tableView registerClass:AGXAlbumTableViewCell.class forCellReuseIdentifier:AGXAlbumCellReuseIdentifier];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_albumModels);
    AGX_RELEASE(_tableView);
    AGX_SUPER_DEALLOC;
}

- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {
    if AGX_EXPECT_F(_allowPickingVideo == allowPickingVideo) return;
    _allowPickingVideo = allowPickingVideo;
    if (_albumModels) [self reloadAlbums];
}

- (void)setAllowPickingGif:(BOOL)allowPickingGif {
    if AGX_EXPECT_F(_allowPickingGif == allowPickingGif) return;
    _allowPickingGif = allowPickingGif;
    if (_albumModels) [self reloadAlbums];
}

- (void)setAllowPickingLivePhoto:(BOOL)allowPickingLivePhoto {
    if AGX_EXPECT_F(_allowPickingLivePhoto == allowPickingLivePhoto) return;
    _allowPickingLivePhoto = allowPickingLivePhoto;
    if (_albumModels) [self reloadAlbums];
}

- (void)setSortByCreateDateDescending:(BOOL)sortByCreateDateDescending {
    if AGX_EXPECT_F(_sortByCreateDateDescending == sortByCreateDateDescending) return;
    _sortByCreateDateDescending = sortByCreateDateDescending;
    if (_albumModels) [self reloadAlbums];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;

    [self reloadAlbums];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AGXAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                   AGXAlbumCellReuseIdentifier forIndexPath:indexPath];
    cell.albumModel = _albumModels[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AGXAlbumCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(albumPickerController:didSelectAlbumModel:)])
        [self.delegate albumPickerController:self didSelectAlbumModel:_albumModels[indexPath.row]];
}

#pragma mark - private methods

- (void)reloadAlbums {
    [self.view showLoadingHUD:YES title:nil];
    agx_async_main
    (self.albumModels = [AGXPhotoManager.shareManager allAlbumModelsAllowPickingVideo:_allowPickingVideo
                                                                      allowPickingGif:_allowPickingGif
                                                                allowPickingLivePhoto:_allowPickingLivePhoto
                                                           sortByCreateDateDescending:_sortByCreateDateDescending];
     [_tableView reloadData];
     agx_async_main([self.view hideHUD];););
}

@end

@implementation AGXAlbumTableViewCell {
    UIImageView *_coverImageView;
    UILabel *_titleLabel;
    AGXLine *_bottomLine;
}

- (AGX_INSTANCETYPE)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if AGX_EXPECT_T(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        [self addSubview:_coverImageView];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];

        _bottomLine = [[AGXLine alloc] init];
        _bottomLine.lineColor = UIColor.lightGrayColor;
        [self addSubview:_bottomLine];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_albumModel);
    AGX_RELEASE(_coverImageView);
    AGX_RELEASE(_titleLabel);
    AGX_RELEASE(_bottomLine);
    AGX_SUPER_DEALLOC;
}

- (void)setAlbumModel:(AGXAlbumModel *)albumModel {
    AGXAlbumModel *temp = AGX_RETAIN(albumModel);
    AGX_RELEASE(_albumModel);
    _albumModel = temp;

    [AGXPhotoManager.shareManager coverImageForAlbumModel:_albumModel size:
     AGXAlbumCellCoverImageSize completion:^(UIImage *image) { _coverImageView.image = image; }];
    NSMutableAttributedString *nameString = [NSMutableAttributedString attrStringWithString:_albumModel.name attributes:
                                             @{NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
                                               NSForegroundColorAttributeName : UIColor.blackColor}];
    NSAttributedString *countString = [NSAttributedString attrStringWithString:
                                       [NSString stringWithFormat:@"  (%zd)", (long)_albumModel.count] attributes:
                                       @{NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
                                         NSForegroundColorAttributeName : UIColor.lightGrayColor}];
    [nameString appendAttributedString:countString];
    _titleLabel.attributedText = nameString;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;

    CGFloat coverImageMargin = (height-AGXAlbumCellCoverImageSize.height)/2;
    _coverImageView.frame = AGX_CGRectMake(CGPointMake(coverImageMargin, coverImageMargin),
                                           AGXAlbumCellCoverImageSize);
    CGFloat coverImageWidth = height+coverImageMargin;
    CGFloat titleLabelHeight = cgceil(_titleLabel.font.lineHeight);
    _titleLabel.frame = CGRectMake(coverImageWidth, (height-titleLabelHeight)/2,
                                   width-coverImageWidth-AGXAlbumCellAccessoryMargin,
                                   titleLabelHeight);
    _bottomLine.frame = CGRectMake(0, height-AGX_SinglePixel, width, AGX_SinglePixel);
}

@end

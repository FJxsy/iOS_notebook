#ifdef IMX_DEBUG_MONITOR
//
//  IMXPerformanceSettingViewController.m
//  IMXPerformance
//
//  Created by Erick on 11/26/14.
//  Copyright (c) 2014 Alipay. All rights reserved.
//


#import "IMXPerformanceSettingViewController.h"
#import "IMXAssistiveControl.h"
#import "IMXPerformanceCommonCell.h"
#import "IMXPerformanceMonitorView.h"
#import "IMXStickyControl.h"
#import <FLEX/FLEXManager.h>
#import <Masonry/Masonry.h>

const static CGFloat kPerformanceSettingWidth = 300;
const static CGFloat kPerformanceSettingHeight = 340;

NSString *const kMtopClientOverrideVersionKey = @"MtopClientOverrideVersionKey";
NSString *const kMtopClientProjectIdKey = @"MtopProjectIdKey";

@interface IMXPerformanceSettingViewController () <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property(nonatomic, strong) IMXStickyControl *performanceStick;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *cells;


@end

@implementation IMXPerformanceSettingViewController

- (void)dealloc {
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}


- (void)loadView {
    UIView *view = [[UIView alloc] init];
    [view setFrame:CGRectMake(0, 0, kPerformanceSettingWidth, kPerformanceSettingHeight)];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kPerformanceSettingWidth, kPerformanceSettingHeight + 44) style:UITableViewStyleGrouped];
    [tableView setDelegate:self];
    [view addSubview:tableView];

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];

    self.tableView = tableView;
    [self.tableView setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];

    self.view = view;

    self.title = NSLocalizedString(@"Debug Monitor", @"Debug Monitor");


    {
        NSDictionary *dic = @{@"title":@"Show PerformanceView",@"dTitle":@""};
        [self.cells addObject:dic];
        
    }

    {
        NSDictionary *dic = @{@"title":@"Show FLEX",@"dTitle":@""};
        [self.cells addObject:dic];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (CGSize)preferredContentSize {
    return CGSizeMake(MAX(IMX_DEBUG_WINDOW_WIDTH - 100, kPerformanceSettingWidth),
        MAX(IMX_DEBUG_WINDOW_HEIGHT - 200, kPerformanceSettingHeight));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

#pragma mark -

- (IBAction)switchNetworkView:(id)sender {

    //TODO: block
}

- (IBAction)switchPerformanceView:(id)sender {
    UISwitch *switchControl = sender;
    if ([switchControl isOn]) {
        IMXPerformanceMonitorView *performanceMonitorView = [[IMXPerformanceMonitorView alloc] init];
        self.performanceStick = [[IMXStickyControl alloc] initWithContentView:performanceMonitorView];
        //        [[DTContextGet() window] addSubview:self.performanceStick];
        [[UIApplication sharedApplication].keyWindow addSubview:self.performanceStick];
    } else {
        [self.performanceStick removeFromSuperview];
        self.performanceStick = nil;
    }
}

- (IBAction)switchFLEXManager:(id)sender {
    UISwitch *switchControl = sender;
    if ([switchControl isOn]) {
        [[FLEXManager sharedManager] showExplorer];
    } else {
        [[FLEXManager sharedManager] hideExplorer];
    }
}

- (void)clearUserDefaults:(id)sender {
  //TODO:
    exit(0);
}



- (void)didPresentAlertView:(UIAlertView *)alertView {

    if (IMX_DEBUG_IOSVersionEqualOrLater(8)) {

        [[alertView textFieldAtIndex:0] becomeFirstResponder];
    }

    [[alertView textFieldAtIndex:0] selectAll:nil];
}

- (void)switchProfile:(id)sender {
    UISwitch *profileSwitch = sender;
    if (profileSwitch.isOn) {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"UseOldProfile"];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"UseOldProfile"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didFindScanResult:(NSString *)result {
}

- (void)didGoBack {
}

- (NSMutableArray *)cells{
    if(!_cells){
        _cells = [[NSMutableArray alloc] init];
    }
    return _cells;
}
#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cells.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [IMXPerformanceCommonCell cellHeight];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    IMXPerformanceCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell =[[IMXPerformanceCommonCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    NSDictionary *dic = self.cells[indexPath.row];
    [cell updateWithTitle:dic[@"title"] detail:dic[@"dTitle"]];
    
    switch (indexPath.row) {
        case 0:
        {
            [cell.onoffSW addTarget:self action:@selector(switchPerformanceView:) forControlEvents:UIControlEventValueChanged];
            [cell.onoffSW setOn:(self.performanceStick != nil)];

        }
            break;
        case 1:
        {
            [cell.onoffSW addTarget:self action:@selector(switchFLEXManager:) forControlEvents:UIControlEventValueChanged];
            [cell.onoffSW setOn:![FLEXManager sharedManager].isHidden];
        }
            break;

        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end

#endif

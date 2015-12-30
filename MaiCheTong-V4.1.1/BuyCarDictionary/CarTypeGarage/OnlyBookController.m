//
//  OnlyBookController.m
//  BuyCarDictionary
//
//  Created by zgjun on 15-2-12.
//  Copyright (c) 2015年 chexun. All rights reserved.
//

#import "OnlyBookController.h"
#import "BookChooseController.h"
#import "SeriesAndTypeController.h"
#import "AFNetworking.h"
#import "InvaliteTool.h"
#import "CityChooseController.h"

#define OnlyBookGap 10

@interface OnlyBookController ()<UITableViewDataSource,UITableViewDelegate,SeriesAndTypeDelegate,BookChooseDelegate,CityChooseControllerDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate>

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) NSString *carSeriesName;

@property (nonatomic,strong) NSString *carTypeName;

@property (nonatomic,strong) NSString *bookName;

@property (nonatomic,weak) UILabel * carSeriesLabel;

@property (nonatomic,weak) UILabel * carTypeLabel;

@property (nonatomic,weak) UILabel * carPriceLabel;

@property (nonatomic,strong) NSString *dealerId;

@property (nonatomic,strong) NSString *dealerName;

@property (nonatomic,strong) NSString *carSeriesId;

@property (nonatomic,strong) NSString *carTypeId;

@property (nonatomic,strong) NSTimer *secondTimer;

@property (nonatomic,assign) NSInteger secondsCount;


@property (nonatomic,weak) UITextField *phoneField;


@property (nonatomic,weak) UITextField *nameField;


@property (nonatomic,weak) UIButton *cityBtn;

@property (nonatomic,strong) NSString *cityId;


@property (nonatomic,strong) NSString *cityStr;

@property (nonatomic,assign) NSInteger type;

@property (nonatomic,weak) UIButton *commitBtn;

@property (nonatomic,strong)  CityChooseController *cityVc;

@end

@implementation OnlyBookController

- (NSString *)cityStr {
    _cityStr = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityNameKey];
    
    if (_cityStr == nil) {
        _cityStr = [NSString stringWithFormat:@"北京"];
    }
    return _cityStr;
}


- (NSString *)cityId {
    _cityId = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCityIDKey];
    
    if (_cityId == nil) {
        _cityId = [NSString stringWithFormat:@"1"];
    }
    return _cityId;
}

- (instancetype)initWithDealerId:(NSString *)dealerId dealerName:(NSString *)dealerName {
    if (self = [super init]) {
        self.dealerId = dealerId;
        self.dealerName = dealerName;
    }
    return self;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (self.navigationController.viewControllers.count == 1){
        
        //关闭主界面的右滑返回
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}



- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer

{
    
    return YES;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.view.backgroundColor = MainBackGroundColor;
    
    self.carSeriesName = @"添加车系（必选）";
    self.carTypeName = @"添加车型（必选）";
    self.bookName = @"预约试驾";
    self.type = 1;
    
    //导航视图
    
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    
    navView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:navView];
    
    
    
    //返回按钮
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 44, 44)];
    
    backBtn.backgroundColor = [UIColor clearColor];
    
    [backBtn setImage:[UIImage imageNamed:@"chexun_backarrow_black"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    
    [navView addSubview:backBtn];
    
    
    
    //标题视图
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - 80) * 0.5, 20, 80, 44)];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.font = [UIFont systemFontOfSize:20];
    
    titleLabel.text = @"专享预约";
    
    [navView addSubview:titleLabel];
    
    //添加分割线
    
    UIView *spliteLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth, 1)];
    spliteLine.backgroundColor = MainLineGrayColor;
    [navView addSubview:spliteLine];
    
    //创建talbeView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    tableView.showsVerticalScrollIndicator = NO;
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"QueryLowPriceCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 80)];
    bottomView.backgroundColor = [UIColor whiteColor];
    //提交信息
    
    UIButton *commitBtn = [[UIButton alloc]initWithFrame:CGRectMake((ScreenWidth - 282) * 0.5, 20, 282, 44)];
    self.commitBtn = commitBtn;
    [commitBtn setTitle:@"提交信息" forState:UIControlStateNormal];
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitBtn setBackgroundImage:[UIImage imageNamed:@"chexun_okbutbg"] forState:UIControlStateNormal];
    [commitBtn addTarget:self action:@selector(commitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:commitBtn];
    
    self.tableView.tableFooterView = bottomView;
    
    //添加键盘的监听通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive) name:@"applicationWillResignActive" object:nil];
}

- (void)dealloc {
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    MyLog(@"%s",__FILE__);
}
- (void)resignActive {
    //    [self.view resignFirstResponder];
    [self.phoneField endEditing:YES];
    [self.nameField endEditing:YES];
}



- (void)commitBtnClick {
    self.commitBtn.enabled = NO;
    
    //判断车系
    if ([self.carSeriesName isEqualToString:@"添加车系（必选）"]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请选择车系！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        self.commitBtn.enabled = YES;
        return;
    }
    
    
    //判断车型
    if ([self.carTypeName isEqualToString:@"添加车型（必选）"]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请选择车型！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        self.commitBtn.enabled = YES;
        return;
    }
    
    //判断姓名
    if (self.nameField.text.length == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请输入姓名！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        [self.nameField becomeFirstResponder];
        self.commitBtn.enabled = YES;
        return;
    }
    
    //判断姓名长度不超过10个字
    if (self.nameField.text.length > 10) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"姓名长度不能超过10，请重新输入！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        [self.nameField becomeFirstResponder];
        self.commitBtn.enabled = YES;
        return;
    }
    
    //判断手机号
    NSString *phone = self.phoneField.text;
    //验证手机号是否合法
    BOOL isPhone = [InvaliteTool checkTel:phone];
    
    if (!isPhone) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请输入正确的手机号！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        [self.phoneField becomeFirstResponder];
        self.commitBtn.enabled = YES;
        return;
    }
    
    NSString *strKey = [InvaliteTool md5Digest:[NSString stringWithFormat:@"%@@CheXun",phone]];
    
    NSString *url = [NSString stringWithFormat:@"http://reg.chexun.com/api/checkvalidcode.ashx?phone=%@&key=%@",phone,strKey];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/html" ,nil];
    
    
    __weak OnlyBookController *myself = self;
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = responseObject[0];
        //判断验证码
        if ([dict[@"code"] integerValue] == -1) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"验证码错误！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            
            [alert show];
            myself.commitBtn.enabled = YES;
            return;
        } else {
            //1:代表试驾 2:代表保养
            
            NSString *commitUrl = [NSString stringWithFormat:@"http://dealer.chexun.com/API/FenFaCarOrderHandler3.ashx?type=%@&phone=%@&seriesId=%@&modelId=%@&contact=%@&cityId=%@&Source=2&dealersId=%@",@(myself.type),phone,myself.carSeriesId,myself.carTypeId,myself.nameField.text,myself.cityId,myself.dealerId];
            
            commitUrl =  CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)commitUrl, NULL, NULL,  kCFStringEncodingUTF8 ));
            
            
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:commitUrl]];
            
            NSURLResponse *response = nil;
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
            NSString *result =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            
            if ([result integerValue] == 1) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"提交成功！"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                
                [alert show];
                myself.commitBtn.enabled = YES;
                return;
            } else {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"提交失败！"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                
                [alert show];
                myself.commitBtn.enabled = YES;
                return;
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"提交失败！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        myself.commitBtn.enabled = YES;
        return;
    }];
    
}

- (void)keyboardWasChange:(NSNotification *)aNotification {
    
    // 0.取出键盘动画的时间
    CGFloat duration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 1.取得键盘最后的frame
    CGRect keyboardFrame = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 2.计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - self.view.frame.size.height;
    
    // 3.执行动画
    if (transformY < 0) {
        [UIView animateWithDuration:duration animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, transformY + 100);
        }];
    } else {
        [UIView animateWithDuration:duration animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, 0);
        }];
    }
    
    
}

- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 1;
    } else {
        return 3;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"QueryLowPriceCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    NSInteger subviewsCount = cell.contentView.subviews.count;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (subviewsCount > 0) {
        //在这里只能用上面的forin,而不能用下面的for循环
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    switch (indexPath.section) {
        case 0:{
            
            if (indexPath.row == 0) {
                UIImageView *foursImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chexun_4sicon"]];
                foursImage.frame = CGRectMake(OnlyBookGap, 15, 18, 14);
                [cell.contentView addSubview:foursImage];
                
                UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(foursImage.frame) + OnlyBookGap, OnlyBookGap, ScreenWidth * 0.45, 24)];
                nameLabel.textColor = MainBlackColor;
                nameLabel.font = [UIFont systemFontOfSize:16];
                nameLabel.text = self.dealerName;
                [cell.contentView addSubview:nameLabel];
                
                UILabel *soldCountry = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame) + OnlyBookGap, OnlyBookGap, 50, 24)];
                soldCountry.textColor = MainFontGrayColor;
                soldCountry.font = [UIFont systemFontOfSize:16];
                soldCountry.text = @"售全国";
                [cell.contentView addSubview:soldCountry];
                
                UILabel *department = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(soldCountry.frame) + OnlyBookGap, OnlyBookGap, 70, 24)];
                department.textColor = MainFontGrayColor;
                department.font = [UIFont systemFontOfSize:16];
                department.text = @"认证商户";
                [cell.contentView addSubview:department];
            } else {
                UILabel * carSeriesLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth - 20, cell.height)];
                carSeriesLabel.text = self.bookName;
                carSeriesLabel.textAlignment = NSTextAlignmentLeft;
                self.carSeriesLabel = carSeriesLabel;
                carSeriesLabel.font = [UIFont systemFontOfSize:16];
                carSeriesLabel.textColor = MainFontGrayColor;
                [cell.contentView addSubview:carSeriesLabel];
                
                UIImageView *indicatorImage = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 15, 18, 5, 8)];
                
                indicatorImage.image = [UIImage imageNamed:@"chexun_liftarrow"];
                
                [cell.contentView addSubview:indicatorImage];
            }
            
            
            UIView *bottomLine = [[UIView alloc]init];
             bottomLine.backgroundColor = MainLineGrayColor;
            bottomLine.frame = CGRectMake(0, cell.height - 1,ScreenWidth, 1);
            [cell.contentView addSubview:bottomLine];
            
            break;
        }
        case 1:{
            UILabel * carSeriesLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth - 20, cell.height)];
            carSeriesLabel.text = self.carSeriesName;
            carSeriesLabel.textAlignment = NSTextAlignmentLeft;
            self.carSeriesLabel = carSeriesLabel;
            carSeriesLabel.font = [UIFont systemFontOfSize:16];
            carSeriesLabel.textColor = MainFontGrayColor;
            [cell.contentView addSubview:carSeriesLabel];
            
            UIImageView *indicatorImage = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 15, 18, 5, 8)];
            
            indicatorImage.image = [UIImage imageNamed:@"chexun_liftarrow"];
            
            [cell.contentView addSubview:indicatorImage];
            break;
        }
        case 2:{
            UILabel * carTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth - 20, 40)];
            self.carTypeLabel = carTypeLabel;
            carTypeLabel.text = self.carTypeName;
            carTypeLabel.textAlignment = NSTextAlignmentLeft;
            carTypeLabel.font = [UIFont systemFontOfSize:16];
            carTypeLabel.textColor = MainFontGrayColor;
            [cell.contentView addSubview:carTypeLabel];
            
            
            UIImageView *indicatorImage = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 15, 18, 5, 8)];
            
            indicatorImage.image = [UIImage imageNamed:@"chexun_liftarrow"];
            
            [cell.contentView addSubview:indicatorImage];
            
            break;
        }
        case 3:{
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row == 0) {
                UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(OnlyBookGap, OnlyBookGap, 100, 24)];
                nameLabel.text = @"姓         名：";
                nameLabel.font = [UIFont systemFontOfSize:16];
                nameLabel.textColor = MainBlackColor;
                [cell.contentView addSubview:nameLabel];
                
                UITextField *nameField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame), OnlyBookGap, 120, 24)];
                nameField.delegate = self;
                nameField.tag = 1;
                nameField.returnKeyType = UIReturnKeyNext;
                self.nameField = nameField;
                nameField.font = [UIFont systemFontOfSize:16];
                nameField.textColor = MainBlackColor;
                [cell.contentView addSubview:nameField];
            } else if (indexPath.row == 1) {
                UILabel *phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(OnlyBookGap, OnlyBookGap, 100, 24)];
                phoneLabel.text = @"手   机   号：";
                phoneLabel.font = [UIFont systemFontOfSize:16];
                phoneLabel.textColor = MainBlackColor;
                [cell.contentView addSubview:phoneLabel];
                
                UITextField *phoneField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(phoneLabel.frame), OnlyBookGap, 120, 24)];
                phoneField.tag = 2;
                phoneField.delegate = self;
                phoneField.keyboardType = UIKeyboardTypeNumberPad;
                phoneField.returnKeyType = UIReturnKeyDone;
                self.phoneField = phoneField;
                phoneField.font = [UIFont systemFontOfSize:16];
                phoneField.textColor = MainBlackColor;
                [cell.contentView addSubview:phoneField];
            } else {
                UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(OnlyBookGap, OnlyBookGap, 100, 24)];
                cityLabel.text = @"城          市：";
                cityLabel.font = [UIFont systemFontOfSize:16];
                cityLabel.textColor = MainBlackColor;
                [cell.contentView addSubview:cityLabel];
                
                UIButton *cityBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(cityLabel.frame), OnlyBookGap, 80, 24)];
                self.cityBtn = cityBtn;
                [cityBtn setTitleColor:MainBlackColor forState:UIControlStateNormal];
                [cityBtn setTitle:self.cityStr forState:UIControlStateNormal];
                cityBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                cityBtn.titleLabel.font = [UIFont systemFontOfSize:16];
                [cityBtn addTarget:self action:@selector(cityBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:cityBtn];
            }
            
            UIView *bottomLine = [[UIView alloc]init];
            bottomLine.backgroundColor = MainLineGrayColor;
            bottomLine.frame = CGRectMake(0, cell.height - 1,ScreenWidth, 1);
            [cell.contentView addSubview:bottomLine];
            
            break;
        }
        default:
            break;
    }
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 30;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *secHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    secHeadView.backgroundColor = MainBackGroundColor;
    
    UILabel *secHeadLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth, 30)];
    [secHeadView addSubview:secHeadLabel];
    
    if (section == 0) {
        secHeadLabel.text = nil;
    } else if (section == 1) {
        secHeadLabel.text = @"车系";
    } else if (section == 2) {
        secHeadLabel.text = @"车型";
    } else {
        secHeadLabel.text = @"个人信息";
    }
    
    return secHeadView;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 1) {
        BookChooseController *bookChooseVc = [[BookChooseController alloc]init];
        bookChooseVc.delegate = self;
        [self.navigationController pushViewController:bookChooseVc animated:YES];
    } else if (indexPath.section == 1) {
        SeriesAndTypeController *seriesAndTypeVc = [[SeriesAndTypeController alloc]initWithDealerId:self.dealerId];
        seriesAndTypeVc.delegate = self;
        [self.navigationController pushViewController:seriesAndTypeVc animated:YES];
    } else if (indexPath.section == 2) {
        
        if (self.carSeriesId == nil) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                  
                                                            message:@"请先选择车系！"
                                  
                                                           delegate:nil
                                  
                                                  cancelButtonTitle:@"确定"
                                  
                                                  otherButtonTitles:nil];
            
            
            
            [alert show];
            
            return;
        }
        
        SeriesAndTypeController *seriesAndTypeVc = [[SeriesAndTypeController alloc]initWithDealerId:self.dealerId carSeriesId:self.carSeriesId priceType:@"noPrice"];
        seriesAndTypeVc.delegate = self;
        [self.navigationController pushViewController:seriesAndTypeVc animated:YES];
    }
}


///城市按钮的点击
- (void)cityBtnClick:(UIButton *)cityBtn {
    
    [self.view endEditing:YES];
    
    CityChooseController *cityVc = [[CityChooseController alloc]init];
    self.cityVc = cityVc;
    cityVc.cityDelegate = self;
    [self.navigationController pushViewController:cityVc animated:YES];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)seriesAndTypeSelected:(NSDictionary *)contentDict {
    if (contentDict[@"seriesId"] != nil) {
        self.carSeriesId = contentDict[@"seriesId"];
        self.carSeriesName = contentDict[@"seriesName"];
        
        //选择车系后，车型也要清空
        self.carTypeId = nil;
        self.carTypeName = @"添加车型（必选）";
        
    } else if (contentDict[@"modelID"] != nil) {
        self.carTypeId = contentDict[@"modelID"];
        self.carTypeName = contentDict[@"modelName"];
    }
    
    [self.tableView reloadData];
}

- (void)bookChooseSelected:(NSString *)selectedName {
    self.bookName = selectedName;
    
    if ([selectedName isEqualToString:@"预约保养"]) {
        self.type = 4;
    } else {
        self.type = 1;
    }
    
    [self.tableView reloadData];
}


//城市控制器的代理方法
- (void)didCityTableRowClick:(CityChooseController *)cityVc infoDict:(NSDictionary *)infoDict {
    
    self.cityId = infoDict[@"cityId"];
    
    [self.cityBtn setTitle:infoDict[@"cityName"] forState:UIControlStateNormal];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 1) {
        [self.phoneField becomeFirstResponder];
    } else if (textField.tag == 2) {
        [textField endEditing:YES];
    }
    
    
    return YES;
}



@end
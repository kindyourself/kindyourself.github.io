---
layout: '[layout]'
title: iOS集成融云SDK即时通讯整理
date: 2018-03-29 14:36:05
tags: [“iOS”, “融云”]
categories: "iOS"
---

#iOS集成融云SDK即时通讯整理

>最近很少写一下项目总结了，最近项目虽然做了很多，但是都是一些外包项目，做下来也没有什么值得总结的。最近一个项目用到了融云即时通讯，以前基本都是用环信，所以还遇到了一些问题，在此总结一下记录一下。

### 1 头像、昵称等用户信息(融云对这个问题有两种处理方式)
#####1.用户信息提供者
实现步骤(以下代码放在单例中，可以是AppDelegate，最好单独写一个单例)  

首先遵守RCIMUserInfoDataSource这个协议 
 
然后是要设置代理  

	[[RCIM sharedRCIM] setUserInfoDataSource:self]; 
 
最后实现代理方法：

	- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
    NSLog(@"getUserInfoWithUserId ----- %@", userId);
    RCUserInfo *user = [RCUserInfo new];
    if (userId == nil || [userId length] == 0) {
        user.userId = userId;
        user.portraitUri = @"";
        user.name = @"";
        completion(user);
        return;
    }
    if ([userId isEqualToString:[UserInfo shareInstance].uid]) {
        NSString *urlSelf = [BASIC_URL_image stringByAppendingString:[UserInfo shareInstance].photo];
        return completion([[RCUserInfo alloc] initWithUserId:userId name:[UserInfo shareInstance].nickname portrait:urlSelf]);
    }else {
        //根据存储联系人信息的模型，通过 userId 来取得对应的name和头像url，进行以下设置
        [WTBaseHttpRequst postRequstWithURL:getUserHttp params:@{@"uid":[UserInfo shareInstance].uid, @"api_token":[UserInfo shareInstance].api_token, @"k_uid":userId} successBlock:^(NSDictionary *returnData) {
            if ([returnData[@"status"] integerValue] == 1) {
                NSString *urlStr = [BASIC_URL_image stringByAppendingString:returnData[@"data"][@"user"][@"photo"]];
                return completion([[RCUserInfo alloc] initWithUserId:userId name:returnData[@"data"][@"user"][@"nickname"] portrait:urlStr]);
            }else {
                completion(user);
            }
        } failureBlock:^(NSString *error) {
            completion(user);
        } showHUD:NO];
    }
	}
这个方法不需要你自己手动调用，只是当你在修改用户信息时调用  

	[[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:[UserInfo shareInstance].uid]
方法即可

	WS(weakSelf);
	// 修改用户信息调用
    [WTBaseHttpRequst postRequstWithURL:modifyInfoHttp params:dict successBlock:^(NSDictionary *returnData) {
        [weakSelf MBProgressHudShowWithTextOnlyWithText:returnData[@"msg"]];
        if ([returnData[@"status"] integerValue] == 1) {
            RCUserInfo *user = [RCUserInfo new];
            user.userId = [UserInfo shareInstance].uid;
            user.portraitUri = [BASIC_URL_image stringByAppendingString:[UserInfo shareInstance].photo];
            user.name = weakSelf.nickNameTextField.text;
            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:[UserInfo shareInstance].uid];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    } failureBlock:^(NSString *error) {
        [weakSelf MBProgressHudShowWithTextOnlyWithText:error];
    } showHUD:YES];

#####2.在扩展消息中携带用户信息#####
*设置发送消息时在消息体中携带用户信息(从2.4.1 之后附加用户信息之后cell默认会显示附加的用户信息的头像，即用户信息不会取用户信息提供者里提供的用户信息)* 

	[RCIM sharedRCIM].enableMessageAttachUserInfo = YES;   
你设置了enableMessageAttachUserInfo之后，可以取到  

	/**  
	*  发送者信息
	*  **/  
	@property(nonatomic, strong) RCUserInfo *senderUserInfo;  
   
***当然我觉得还可以从后台获取好友关系后，我们在每次登陆后，开一个线程把好友关系请求下来存起来然后根据环信ID查找好友的昵称和头像***


### 2 给输入框添加提示语(这个我一直觉得环信应该给了方法修改，只是我一直没有找到这个方法，所以只有自己去写了)
  
#####1.创建提示的label
	_lab = [[UILabel alloc] initWithFrame:self.chatSessionInputBarControl.inputTextView.bounds];
    _lab.text = @"请输入文字信息...";
    _lab.textColor = [UIColor colorWithHexColor:@"dddddd"];
    _lab.font = [UIFont systemFontOfSize:15];
    _lab.center = CGPointMake(_lab.center.x + 15, _lab.center.y);
#####2.判定是否有草稿来显示和隐藏提示的label
    [self.chatSessionInputBarControl.inputTextView addSubview:_lab];
    if (self.chatSessionInputBarControl.draft == nil || self.chatSessionInputBarControl.draft.length == 0) {
        _lab.hidden = NO;
    }else {
        _lab.hidden = YES;
    }
#####3.根据输入数据来判定显示隐藏提示label
	- (void)inputTextView:(UITextView *)inputTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (((inputTextView.text.length == 1 && [text isEqualToString:@""]) || (inputTextView.text.length == 0 && text.length > 0))  && range.length == 1 && range.location == 0) {
        _lab.hidden = NO;
    }else {
        _lab.hidden = YES;
    }
}

### 3 取消输入@弹出好友列表界面，保留长按头像@方法

#####1.首先在AppDelegate中开启消息@功能（只支持群聊和讨论组, App需要实现群成员数据源groupMemberDataSource）
    [RCIM sharedRCIM].enableMessageMentioned = YES;
 然后在继承RCConversationViewController的控制器中调用
 
 	-(void)showChooseUserViewController:(void (^)(RCUserInfo *selectedUserInfo))selectedBlock
                             cancel:(void (^)())cancelBlock {
    
}


### 4 在会话列表中添加一些固定的cell(继承RCConversationListViewController)
 	// 对自定义cell赋值
 	- (RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView
                                  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCCustomCell *cell = (RCCustomCell *)[[RCCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RCCustomCell"];
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    cell.nameLabel.text = model.conversationTitle;
    return cell;
}

	// 添加自定义cell的数据源
	- (NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource{
    NSArray *arr = @[@"论坛回复和@我的", @"陌生人私信", @"幸存者部落@我的", @"问卷调查"];
    for (int i = 0; i<arr.count; i++) {
        RCConversationModel *model = [[RCConversationModel alloc]init];
        model.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
        model.conversationTitle = arr[i];
        model.isTop = YES;
        [dataSource insertObject:model atIndex:i];
    }
    return dataSource;
}

	// 点击cell跳转
	- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        WTForumAndConnectListViewController *chatList = (WTForumAndConnectListViewController *)[WTStoryBoardSegment instantiateViewControllerWithStoryBoardName:@"Main" identifier:@"WTForumAndConnectListViewController"];
        chatList.title = @"回复和@我的";
        [self.navigationController pushViewController:chatList animated:YES];
    }else if (indexPath.row == 1) {
        WTChatListViewController *chatList = [[WTChatListViewController alloc] init];
        chatList.title = @"陌生人私信";
        chatList.isEnteredToCollectionViewController = YES;
        chatList.type = 1;
        chatList.friendArray = self.friendArray;
        [self.navigationController pushViewController:chatList animated:YES];
    }else if (indexPath.row == 2) {
        WTChatListViewController *chatList = [[WTChatListViewController alloc] init];
        chatList.title = @"幸存者部落@我的";
        chatList.isEnteredToCollectionViewController = YES;
        chatList.type = 2;
        [self.navigationController pushViewController:chatList animated:YES];
    }else if (indexPath.row == 3) {
        WTQuestionnaireViewController *questionnaire = (WTQuestionnaireViewController *)[WTStoryBoardSegment instantiateViewControllerWithStoryBoardName:@"Main" identifier:@"WTQuestionnaireViewController"];
        [self.navigationController pushViewController:questionnaire animated:YES];
    }else {
        //点击cell，拿到cell对应的model，然后从model中拿到对应的RCUserInfo，然后赋值会话属性，进入会话
        if (model.conversationType == ConversationType_PRIVATE) {//单聊
            WTMyConversationLisViewController *_conversationVC = [[WTMyConversationLisViewController alloc]init];
            _conversationVC.conversationType = model.conversationType;
            _conversationVC.targetId = model.targetId;
            _conversationVC.title = model.conversationTitle;
            [self.navigationController pushViewController:_conversationVC animated:YES];
        }else if (model.conversationType == ConversationType_GROUP){//群聊
            WTMyConversationLisViewController *_conversationVC = [[WTMyConversationLisViewController alloc]init];
            _conversationVC.conversationType = model.conversationType;
            _conversationVC.title = model.conversationTitle;
            _conversationVC.targetId = model.targetId;
            [self.navigationController pushViewController:_conversationVC animated:YES];
        }
    }
}

### 5 在任意地方获取聊天列表数量及删除列表
获取聊天列表   

	NSArray *privateArr = [[RCIMClient sharedRCIMClient] getConversationList:@[@(ConversationType_PRIVATE)]];

在ConversationList添加对应类型的聊天就可以获取对应类型的聊天列表删除方法类似

	[[RCIMClient sharedRCIMClient] clearConversations:@[@(ConversationType_PRIVATE)]];

### 6 背景图
融云聊天列表没有数据的默认图片下面有点击右上角加入聊天，可是不是所有的聊天都有这个功能(我的就没有)如何没有就可以在资源文件中找到 no\_message\_img 这张图片用ps去掉下面的那一行字
### 7 其它
以上就是我在使用融云过程中遇到的一些问题及解决方法，如果有错误或者不足之处还望指正，谢谢！

//
//  TreeTableView.m
//  TreeTableView
//
//  Created by yixiang on 15/7/3.
//  Copyright (c) 2015年 yixiang. All rights reserved.
//

#import "TreeTableView.h"
#import "Node.h"
#import "TheProjectCell.h"

@interface TreeTableView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic , strong) NSArray *data;//传递过来已经组织好的数据（全量数据）
@property (retain, strong) NSString *type;
@property (nonatomic , strong) NSMutableArray *tempData;//用于存储数据源（部分数据）


@end

@implementation TreeTableView

-(instancetype)initWithFrame:(CGRect)frame withData : (NSArray *)data type: (NSString*)type{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        _data = data;
        _tempData = [self createTempData:data];
        _type = type;
    }
    return self;
}

/**
 * 初始化数据源
 */
-(NSMutableArray *)createTempData : (NSArray *)data{
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i=0; i<data.count; i++) {
        Node *node = [_data objectAtIndex:i];
        if (node.expand) {
            [tempArray addObject:node];
        }
    }
    //尝试展开到第2层
//    for (int i=0; i<data.count; i++) {
//        Node *node = [_data objectAtIndex:i];
//        if (node.depth == 0) {
//            node.expand = TRUE;
//            [tempArray addObject:node];
//        }
//    }
//    for (int i=0; i<data.count; i++) {
//        Node *node = [_data objectAtIndex:i];
//        if (node.depth == 1){
//            node.expand = TRUE;
//            [tempArray addObject:node];
//        }
//    }
//    for (int i=0; i<data.count; i++) {
//        Node *node = [_data objectAtIndex:i];
//        if (node.depth == 2) {
//            node.expand = TRUE;
//            [tempArray addObject:node];
//        }
//    }
    return tempArray;
}


#pragma mark - UITableViewDataSource

#pragma mark - Required

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tempData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"treeNodeCell";
    UINib *nib = [UINib nibWithNibName:@"TheProjectCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    TheProjectCell *cell = (TheProjectCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Node *node = [_tempData objectAtIndex:indexPath.row];
    cell.treeNode = node;

    switch (node.depth) {
        case 0:
            [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"00_arrow_right"]];
            //cell.cellLabel.layer.backgroundColor = [UIColor colorWithRed:232.0f/255.0f green:232.0f/255.0f blue:232.0f/255.0f alpha:1.0].CGColor;
            break;
        case 1:
            [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"01_arrow_right"]];
            //cell.cellLabel.layer.backgroundColor = [UIColor colorWithRed:86.0f/255.0f green:143.0f/255.0f blue:213.0f/255.0f alpha:1.0].CGColor;
            break;
        case 2:
            [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"02_arrow_right"]];
            //cell.cellLabel.layer.backgroundColor = [UIColor colorWithRed:88.0f/255.0f green:120.0f/255.0f blue:145.0f/255.0f alpha:1.0].CGColor;
            break;
        default:
            if ([_type isEqualToString: @"3"]) {
                [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"ShiYan"]];
            }
            else
            {
                [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"BanHe"]];
            }
            //cell.cellLabel.layer.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0].CGColor;
            break;
    }
    cell.cellLabel.text = node.name;
    
    cell.cellLabel.layer.cornerRadius = 5;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    [cell setNeedsDisplay];
    return cell;
}

#pragma mark - Optional
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

#pragma mark - UITableViewDelegate

#pragma mark - Optional
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //先修改数据源
    Node *parentNode = [_tempData objectAtIndex:indexPath.row];
    if (_treeTableCellDelegate && [_treeTableCellDelegate respondsToSelector:@selector(cellClick:)]) {
        [_treeTableCellDelegate cellClick:parentNode];
    }
    
    NSUInteger startPosition = indexPath.row+1;
    NSUInteger endPosition = startPosition;
    BOOL expand = NO;
    for (int i=0; i<_data.count; i++) {
        Node *node = [_data objectAtIndex:i];
        bool b = [node.parentId isEqualToString:parentNode.nodeId];
        if (b) {
            node.expand = !node.expand;
            if (node.expand) {
                [_tempData insertObject:node atIndex:endPosition];
                expand = YES;
                endPosition++;
            }else{
                expand = NO;
                endPosition = [self removeAllNodesAtParentNode:parentNode];
                break;
            }
        }
    }
    
    //获得需要修正的indexPath
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (NSUInteger i=startPosition; i<endPosition; i++) {
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPathArray addObject:tempIndexPath];
    }
    
    TheProjectCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.treeNode = parentNode;
    //插入或者删除相关节点
    if (expand) {
        switch (parentNode.depth) {
            case 0:
                [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"00_arrow_down"]];
                //cell.cellLabel.layer.backgroundColor = [UIColor colorWithRed:232.0f/255.0f green:232.0f/255.0f blue:232.0f/255.0f alpha:1.0].CGColor;
                break;
            case 1:
                [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"01_arrow_down"]];
                //cell.cellLabel.layer.backgroundColor = [UIColor colorWithRed:86.0f/255.0f green:143.0f/255.0f blue:213.0f/255.0f alpha:1.0].CGColor;
                break;
            case 2:
                [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"02_arrow_down"]];
                //cell.cellLabel.layer.backgroundColor = [UIColor colorWithRed:88.0f/255.0f green:120.0f/255.0f blue:145.0f/255.0f alpha:1.0].CGColor;
                break;
            default:
                if ([_type isEqualToString: @"3"]) {
                    [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"ShiYan"]];
                }
                else
                {
                    [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"BanHe"]];
                }
                //cell.cellLabel.layer.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0].CGColor;
                break;
        }
        [self insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    }else{
        switch (parentNode.depth) {
            case 0:
                [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"00_arrow_right"]];
                //cell.cellLabel.layer.backgroundColor = [UIColor colorWithRed:232.0f/255.0f green:232.0f/255.0f blue:232.0f/255.0f alpha:1.0].CGColor;
                break;
            case 1:
                [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"01_arrow_right"]];
                //cell.cellLabel.layer.backgroundColor = [UIColor colorWithRed:86.0f/255.0f green:143.0f/255.0f blue:213.0f/255.0f alpha:1.0].CGColor;
                break;
            case 2:
                [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"02_arrow_right"]];
                //cell.cellLabel.layer.backgroundColor = [UIColor colorWithRed:88.0f/255.0f green:120.0f/255.0f blue:145.0f/255.0f alpha:1.0].CGColor;
                break;
            default:
                if ([_type isEqualToString: @"3"]) {
                    [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"ShiYan"]];
                }
                else
                {
                    [cell setTheButtonBackgroundImage:[UIImage imageNamed:@"BanHe"]];
                }
                //cell.cellLabel.layer.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0].CGColor;
                break;
        }
        //shao Add End
        [self deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    }
    [cell setNeedsDisplay];
}

/**
 *  删除该父节点下的所有子节点（包括孙子节点）
 *
 *  @param parentNode 父节点
 *
 *  @return 该父节点下一个相邻的统一级别的节点的位置
 */
-(NSUInteger)removeAllNodesAtParentNode : (Node *)parentNode{
    NSUInteger startPosition = [_tempData indexOfObject:parentNode];
    NSUInteger endPosition = startPosition;
    for (NSUInteger i=startPosition+1; i<_tempData.count; i++) {
        Node *node = [_tempData objectAtIndex:i];
        endPosition++;
        if (node.depth <= parentNode.depth) {
            break;
        }
        if(endPosition == _tempData.count-1){
            endPosition++;
            node.expand = NO;
            break;
        }
        node.expand = NO;
    }
    if (endPosition>startPosition) {
        [_tempData removeObjectsInRange:NSMakeRange(startPosition+1, endPosition-startPosition-1)];
    }
    return endPosition;
}

@end

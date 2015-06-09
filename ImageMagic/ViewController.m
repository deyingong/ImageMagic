//
//  ViewController.m
//  ImageMagic
//
//  Created by gongdeyin on 6/3/15.
//  Copyright (c) 2015 gongdeyin. All rights reserved.
//

#import "ViewController.h"

#define IMAGE_TIME                  3

@interface ViewController ()
@property(nonatomic,strong) NSMutableArray *dataList;
@property(nonatomic,strong) NSTableView    *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    self.dataList = [NSMutableArray array];
    
    [super viewDidLoad];
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(400, 150, 100, 60 )];
    [self.view addSubview:button];
    [button setButtonType:NSMomentaryLightButton];
    button.target = self;
    [button setBezelStyle:NSRoundedBezelStyle];
    button.action = @selector(buttonPress:);
    button.title = @"选择图片";
    
    NSButton *button1 = [[NSButton alloc] initWithFrame:NSMakeRect(400,50, 100, 60)];
    [self.view addSubview:button];
    [button1 setButtonType:NSPushOnPushOffButton];
    button1.target = self;
    [button1 setBezelStyle:NSRoundedBezelStyle];
    button1.action = @selector(cutImages);
    button1.title = @"裁剪图片";
    [self.view addSubview:button1];
    
 
    NSScrollView *talbeViewContent = [[NSScrollView alloc] initWithFrame:NSMakeRect(10,0, 400, self.view.frame.size.height - 10)];
    
    self.tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 400, self.view.frame.size.height-10)];
    [self.tableView setHeaderView:nil];
    
    NSTableColumn * column1 = [[NSTableColumn alloc] initWithIdentifier:@"col1"];
    [column1.headerCell setTitle:@"图片"];
    [column1 setWidth:250];
    [self.tableView addTableColumn:column1];
    
    [talbeViewContent setDocumentView:self.tableView];
    [talbeViewContent setHasVerticalScroller:YES];
    [talbeViewContent setHasHorizontalScroller:YES];
    [[self.tableView cell]setLineBreakMode:NSLineBreakByTruncatingTail];
    [[self.tableView cell]setTruncatesLastVisibleLine:YES];
    
    [self.tableView sizeLastColumnToFit];
    [self.tableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    
    //[tableView setAllowsTypeSelect:YES];
    //设置允许多选
    [self.tableView setAllowsMultipleSelection:NO];
    
    [self.tableView setAllowsExpansionToolTips:YES];
    [self.tableView setAllowsEmptySelection:YES];
    [self.tableView setAllowsColumnSelection:YES];
    [self.tableView setAllowsColumnResizing:YES];
    [self.tableView setAllowsColumnReordering:YES];

    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];

    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.view addSubview:talbeViewContent];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dataList.count;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 50;
}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSCell *cell = [[NSCell alloc] initTextCell:[self.dataList objectAtIndex:row]];
    cell.type = NSTextCellType;
    return cell;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [NSString stringWithFormat:@"%ld--%@",row,[self.dataList objectAtIndex:row]];
}

-(void)buttonPress:(NSButton *)button {
    int i; // Loop counter.
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];
    openDlg.allowsMultipleSelection = YES;
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg filenames];
        self.dataList = [files mutableCopy];
        [self.tableView reloadData];
    }
}

- (void)cutImages
{
    if (self.dataList.count == 0) {
        return;
    }
    
    NSMutableArray  *imageNames = [NSMutableArray array];
    
    for (NSString *pathItem in self.dataList) {
        NSMutableArray *paths = [[pathItem componentsSeparatedByString:@"/"] mutableCopy];
        NSString *imageFullName = [paths lastObject];
        NSMutableCharacterSet *charSet = [NSMutableCharacterSet whitespaceCharacterSet];
        [charSet addCharactersInString:@".jpg"];
        [charSet addCharactersInString:@".png"];
        
        [imageNames addObject:[imageFullName stringByTrimmingCharactersInSet:charSet]];
    }
    
     NSString *path = [self.dataList firstObject];
    __block  NSMutableArray *paths = [[path componentsSeparatedByString:@"/"] mutableCopy];
    [paths removeLastObject];
    
    NSString *joinedPath = [paths componentsJoinedByString:@"/"];
    NSLog(@"11%@",joinedPath);
    NSFileManager *mananger = [NSFileManager  defaultManager];
    [paths removeAllObjects];
    for (NSInteger index = 1; index <= IMAGE_TIME; index ++) {
        NSString *newPath = [NSString stringWithFormat:@"%@/%ldx",joinedPath,index];
        if (![mananger fileExistsAtPath:newPath]) {
          BOOL isSuc = [mananger createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
            if (isSuc) {
                NSLog(@"create %@  suc",newPath);
            }
        }else {
            NSLog(@"%@ has exist",newPath);
        }
        
        [paths addObject:newPath];
    }
    
    if (paths.count != 3) {
        return;
    }
    
    NSArray *copyPath = [paths copy];
    
    for( NSInteger i = 0; i < [self.dataList count]; i++ )
    {
        NSString *imageName = [imageNames objectAtIndex:i];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSString* fileName = [self.dataList objectAtIndex:i];
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:fileName];
            paths = [NSMutableArray arrayWithArray:copyPath];
            for (NSInteger index = 1; index <=3; index++) {
                NSImage *image2 =  [NSImage imageWithSize:NSMakeSize(image.size.width / index, image.size.height / index) flipped:YES drawingHandler:^BOOL(NSRect dstRect) {
                    [image drawInRect:dstRect];
                    return YES;
                }];
                
                NSBitmapImageRep *bitmaps = [[NSBitmapImageRep alloc] initWithData:[image2 TIFFRepresentation]];
                NSData *newImageData = nil;
                
                newImageData = [bitmaps representationUsingType:NSPNGFileType properties:[NSDictionary dictionaryWithObjectsAndKeys:@(0.2),NSImageCompressionFactor,nil]];
                NSString *imagePath = nil;
                if ([paths count] == 1) {
                    imagePath = [NSString stringWithFormat:@"%@/%@.png",[paths lastObject],imageName];
                } else {
                    imagePath = [NSString stringWithFormat:@"%@/%@@%ldx.png",[paths lastObject],imageName,[paths count]];
                }
                BOOL isWrite = [newImageData writeToFile:imagePath atomically:YES];
                if (isWrite) {
                    NSLog(@"suc %@",imageName);
                    [paths removeLastObject];
                }
            }
        }];
  }
    
    [self.dataList removeAllObjects];
    [self.tableView reloadData];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

@end

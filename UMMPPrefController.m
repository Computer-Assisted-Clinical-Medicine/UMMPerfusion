//
//  UMMPPrefController.m
//  UMMPerfusion
//
//  Created by Sven Kaiser on 02.11.11.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "UMMPPrefController.h"
#import "UMMPPanelController.h"
#import "UMMPPreset.h"
#import "UMMPUserDefaults.h"
#import <OsiriXAPI/Notifications.h>

#define PresetsTableViewDataType @"de.umm.ummperfusion.PresetTableViewDataType"

@implementation UMMPPrefController

@synthesize presets;
@synthesize maxIterations;
@synthesize maxFunctionEvaluation;
@synthesize extROIFilename;
@synthesize extROI;
@synthesize extROIExists;
@synthesize extROIFilePathForReport;

enum {
    general = 0,
    presetValues,
    mapSelection,
    mpFit,
    aifImport
};

- (id)init {
    self = [super init];
    aifExportData = [[NSMutableArray alloc] init];
    return self;
}

- (id)initWithPanelController:(UMMPPanelController *)givenPanelController
{
    
    self = [super initWithWindowNibName:@"UMMPPreferencePanel"];
    if (self) {
        panelController = givenPanelController;
        extROIFilePathForReport = [[NSMutableString alloc] initWithString:@""];
        extROIFilename = [[NSString alloc] init];
    }
    return self;
}

-(void)initValues
{
    NSData *archive = [[panelController userDefaults] obj:@"UMMPPresets" otherwise:nil];
    NSString *maxIterationData = [[panelController userDefaults] string:@"UMMPMaxIterations" otherwise:nil];
    NSString *maxFunctionEvaluationData = [[panelController userDefaults] string:@"UMMPMaxFunctionEvaluation" otherwise:nil];
    
    if (archive) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
        presets = [[NSMutableArray arrayWithArray:array] retain];
    } else {
        presets = [[NSMutableArray alloc] init];
        UMMPPreset *presetItem = [[UMMPPreset alloc] init];
        [presets addObject: presetItem];
        [presetItem release];
    }
    
    if (!maxIterationData) {
        [[panelController userDefaults] setString:@"200" forKey:@"UMMPMaxIterations"];
    }
    if (!maxFunctionEvaluationData) {
        [[panelController userDefaults] setString:@"1000" forKey:@"UMMPMaxFunctionEvaluation"];
    }
    if (![[panelController userDefaults] keyExists:@"soundOnMapsCalcEnd"]) {
        [[panelController userDefaults] setInt:1 forKey:@"soundOnMapsCalcEnd"];
    }
    if (![[panelController userDefaults] keyExists:@"soundOnAllMapsCalcEnd"]) {
        [[panelController userDefaults] setInt:1 forKey:@"soundOnAllMapsCalcEnd"];
    }
    if (![[panelController userDefaults] keyExists:@"printPresetsToConsole"]) {
        [[panelController userDefaults] setInt:1 forKey:@"printPresetsToConsole"];
    }
    if (![[panelController userDefaults] keyExists:@"useExternalAifCheckBox"]) {
        [[panelController userDefaults] setInt:0 forKey:@"useExternalAifCheckBox"];
    }
    if(![[panelController userDefaults] keyExists:@"aifImportValidation"]){
        [[panelController userDefaults] setInt:0 forKey:@"aifImportValidation"];
    }
    
	[presetsTableView reloadData];
	[parametersTableView reloadData];
    [self refreshStatusOfMapSelection];
	[self setRemoveButtonState];
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:nil];
	
    [presetsTableView registerForDraggedTypes:[NSArray arrayWithObject:PresetsTableViewDataType]];
    
    [presetsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    [self setRemoveButtonState];
    
    [_toolbar setSelectedItemIdentifier:@"general"];
    [self changeViewForTag:0];
    
    [self refreshStatusOfMapSelection];
    
	[maxIterations setIntValue: [[[panelController userDefaults] string:@"UMMPMaxIterations" otherwise:nil] intValue]];
    [maxFunctionEvaluation setIntValue: [[[panelController userDefaults] string:@"UMMPMaxFunctionEvaluation" otherwise:nil] intValue]];
    [soundOnMapsCalcEnd setState:[[panelController userDefaults] int:@"soundOnMapsCalcEnd" otherwise:0]];
    [soundOnAllMapsCalcEnd setState:[[panelController userDefaults] int:@"soundOnAllMapsCalcEnd" otherwise:0]];
    [printPresetsToConsole setState:[[panelController userDefaults] int:@"printPresetsToConsole" otherwise:0]];
    
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [self refreshStatusOfMapSelection];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [aifExportData release]; aifExportData = nil;
    [extROIFilePathForReport release]; extROIFilePathForReport = nil;
    [extROIFilename release]; extROIFilename = nil;
    [super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification
{
    
	/* ACHTUNG TEST */
	if ([notification object] == [self window]) {
        //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:presets];
        //[defaults setObject:archive forKey:@"UMMPpresets"];
        [[panelController userDefaults] setObj:archive forKey:@"UMMPPresets"];
		if ([maxIterations intValue] < 1 || [maxIterations intValue] > 999) {
            [[panelController userDefaults] setString:@"200" forKey:@"UMMPMaxIterations"];
			//[[NSUserDefaults standardUserDefaults] setValue:@"200" forKey:@"UMMPmaxIterations"];
        } else {
			[[panelController userDefaults] setString:[maxIterations stringValue] forKey:@"UMMPMaxIterations"];
			//[[NSUserDefaults standardUserDefaults] setValue:[maxIterations stringValue] forKey:@"UMMPmaxIterations"];
        }
        [maxIterations setStringValue:[[panelController userDefaults] string:@"UMMPMaxIterations" otherwise:nil]];
    }
}


- (IBAction)addPresetItem:(id)sender
{
    [presets addObject: [[UMMPPreset alloc] init]];
    [presetsTableView noteNumberOfRowsChanged];
    NSInteger rowIndex = [presets count]-1;
    [presetsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex]
                  byExtendingSelection:NO];
    [[panelController algorithmController] loadPresets:presets];
    [self setRemoveButtonState];
}

- (void)addPresetItemForNewVersion
{
	[presets addObject: [[UMMPPreset alloc] init]];
    [presetsTableView noteNumberOfRowsChanged];
    NSInteger rowIndex = [presets count]-1;
    [presetsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex]
                  byExtendingSelection:NO];
    [[panelController algorithmController] loadPresets:presets];
    [self setRemoveButtonState];
	
}

- (IBAction)removePresetItem:(id)sender
{
    NSUInteger numberIndexes = [[presetsTableView selectedRowIndexes] count];
    if ([presets count] > 1 && numberIndexes != [presets count]) {
        NSIndexSet *indexes = [presetsTableView selectedRowIndexes];
        [presets removeObjectsAtIndexes:indexes];
        [presetsTableView noteNumberOfRowsChanged];
    }
    [presetsTableView reloadData];
    [parametersTableView reloadData];
    [[panelController algorithmController] loadPresets:presets];
    [self setRemoveButtonState];
}

- (void)removeAllPresetItems
{
	[presets removeAllObjects];
    [presetsTableView noteNumberOfRowsChanged];
    [presetsTableView reloadData];
    [parametersTableView reloadData];
    [[panelController algorithmController] loadPresets:presets];
    [self setRemoveButtonState];
	
}

- (IBAction)exportPreset:(id)sender
{
    NSInteger presetIndex = [presetsTableView selectedRow];
    UMMPPreset *preset = [presets objectAtIndex: presetIndex];
    NSData *presetData = [NSKeyedArchiver archivedDataWithRootObject: preset];
    
    NSSavePanel *savePanelObj	= [NSSavePanel savePanel];
    int status = [savePanelObj runModal];
    if (status == NSOKButton)
    {
     	NSURL *urlPath = [savePanelObj URL];
        NSString *filename = [urlPath path];
        [presetData writeToFile: filename atomically:YES];
    }
}

- (IBAction)importPreset:(id)sender
{
    NSSavePanel *openPanelObj	= [NSOpenPanel openPanel];
    int status = [openPanelObj runModal];
    if (status == NSOKButton)
    {
     	NSURL *urlPath = [openPanelObj URL];
        NSString *filename = [urlPath path];
        NSData *presetData = [NSData dataWithContentsOfFile: filename];
        if (presetData)
        {
            UMMPPreset *preset = [[NSKeyedUnarchiver unarchiveObjectWithData: presetData] retain];
            if (preset)
            {
                [presets addObject: preset];
                [presetsTableView reloadData];
                [self setRemoveButtonState];
            }
        }
    }
}

- (IBAction)pushAlgorithmButton:(id)sender
{
    [parametersTableView reloadData];
}

- (IBAction)pushSelectAllButton:(id)sender
{
    [[panelController userDefaults] setBool:YES forKey:@"UMMPcompartmentMapPF"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPcompartmentMapPMTT"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPcompartmentMapPV"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPcompartmentMapAFE"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPcompartmentMapCS"];
    
    [[panelController userDefaults] setBool:YES forKey:@"UMMPexchangeMapPF"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPexchangeMapPMTT"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPexchangeMapPV"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPexchangeMapIMTT"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPexchangeMapIV"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPexchangeMapEF"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPexchangeMapPSAP"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPexchangeMapAFE"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPexchangeMapCS"];
    
    [[panelController userDefaults] setBool:YES forKey:@"UMMPfiltrationMapPF"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPfiltrationMapPMTT"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPfiltrationMapPV"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPfiltrationMapIMTT"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPfiltrationMapEF"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPfiltrationMapPSAP"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPfiltrationMapAFE"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPfiltrationMapCS"];
    
    [[panelController userDefaults] setBool:YES forKey:@"UMMPuptakeMapPF"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPuptakeMapPMTT"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPuptakeMapPV"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPuptakeMapEF"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPuptakeMapPSAP"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPuptakeMapAFE"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPuptakeMapCS"];
    
    [[panelController userDefaults] setBool:YES forKey:@"UMMPtoftsMapPV"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPtoftsMapIMTT"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPtoftsMapIV"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPtoftsMapPSAP"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPtoftsMapAFE"];
    [[panelController userDefaults] setBool:YES forKey:@"UMMPtoftsMapCS"];
    
    [self refreshStatusOfMapSelection];
    
}

- (IBAction)pushDeselectAllButton:(id)sender
{
    [[panelController userDefaults] setBool:NO forKey:@"UMMPcompartmentMapPF"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPcompartmentMapPMTT"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPcompartmentMapPV"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPcompartmentMapAFE"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPcompartmentMapCS"];
    
    [[panelController userDefaults] setBool:NO forKey:@"UMMPexchangeMapPF"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPexchangeMapPMTT"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPexchangeMapPV"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPexchangeMapIMTT"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPexchangeMapIV"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPexchangeMapEF"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPexchangeMapPSAP"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPexchangeMapAFE"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPexchangeMapCS"];
    
    [[panelController userDefaults] setBool:NO forKey:@"UMMPfiltrationMapPF"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPfiltrationMapPMTT"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPfiltrationMapPV"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPfiltrationMapIMTT"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPfiltrationMapEF"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPfiltrationMapPSAP"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPfiltrationMapAFE"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPfiltrationMapCS"];
    
    [[panelController userDefaults] setBool:NO forKey:@"UMMPuptakeMapPF"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPuptakeMapPMTT"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPuptakeMapPV"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPuptakeMapEF"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPuptakeMapPSAP"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPuptakeMapAFE"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPuptakeMapCS"];
    
    [[panelController userDefaults] setBool:NO forKey:@"UMMPtoftsMapPV"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPtoftsMapIMTT"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPtoftsMapIV"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPtoftsMapPSAP"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPtoftsMapAFE"];
    [[panelController userDefaults] setBool:NO forKey:@"UMMPtoftsMapCS"];
    
    [self refreshStatusOfMapSelection];
    
}

- (IBAction)pushSetDefaultMPFitButton:(id)sender
{
    [[panelController userDefaults] setString:@"200" forKey:@"UMMPMaxIterations"];
    [[panelController userDefaults] setString:@"1000" forKey:@"UMMPMaxFunctionEvaluation"];
    
    [maxIterations setStringValue:@"200"];
    [maxFunctionEvaluation setStringValue:@"1000"];
}

#pragma mark -
#pragma mark TableView delegates

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSTableView *tableView = [aNotification object];
    if (tableView == presetsTableView) {
        [parametersTableView reloadData];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == presetsTableView) {
        return [presets count];
    } else if (tableView == parametersTableView) {
        NSString *algorithmTitle = [selectedAlgorithm titleOfSelectedItem];
        NSInteger presetsRow = [presetsTableView selectedRow];
        if (presetsRow < 0 || presetsRow > [presets count])
            return 0;
        NSMutableArray *parameters = [[[presets objectAtIndex:presetsRow] algorithms] objectForKey:algorithmTitle];
        return [parameters count];
    } else {
        return 0;
    }
    
    return 0;
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    if (tableView == presetsTableView) {
        NSString *name = [[presets objectAtIndex:row] name];
        return name;
    } else if (tableView == parametersTableView) {
        NSInteger presetsRow = [presetsTableView selectedRow];
        UMMPPreset *preset = [presets objectAtIndex:presetsRow];
        NSMutableDictionary *dict = [preset algorithms];
        NSString *algorithmTitle = [selectedAlgorithm titleOfSelectedItem];
        NSMutableArray *array = [dict objectForKey: algorithmTitle];
        UMMPParameter *parameter = [array objectAtIndex:row];
        id param = [parameter valueForKey:[tableColumn identifier]];
        
        return param;
    } else {
        return nil;
    }
}

- (NSString *)tableView:(NSTableView *)aTableView
         toolTipForCell:(NSCell *)aCell
                   rect:(NSRectPointer)rect
            tableColumn:(NSTableColumn *)aTableColumn
                    row:(NSInteger)row
          mouseLocation:(NSPoint)mouseLocation
{
    NSString *toolTip = @"";
    if (aTableView == parametersTableView) {
        if ([[aTableColumn identifier] isEqualToString:@"name"]) {
            NSInteger presetsRow = [presetsTableView selectedRow];
            UMMPPreset *preset = [presets objectAtIndex:presetsRow];
            NSMutableDictionary *dict = [preset algorithms];
            NSString *algorithmTitle = [selectedAlgorithm titleOfSelectedItem];
            NSMutableArray *array = [dict objectForKey: algorithmTitle];
            UMMPParameter *parameter = [array objectAtIndex:row];
            toolTip = [parameter valueForKey:@"toolTip"];
        }
    }
    return toolTip;
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)aTableColumn
              row:(NSInteger)rowIndex
{
    if (aTableView == presetsTableView) {
        [[presets objectAtIndex:rowIndex] setValue:anObject forKey:[aTableColumn identifier]];
        [[panelController algorithmController] loadPresets:presets];
    } else if (aTableView == parametersTableView) {
        NSInteger presetsRow = [presetsTableView selectedRow];
        UMMPPreset *preset = [presets objectAtIndex:presetsRow];
        NSMutableDictionary *dict = [preset algorithms];
        NSString *algorithmTitle = [selectedAlgorithm titleOfSelectedItem];
        NSMutableArray *array = [dict objectForKey: algorithmTitle];
        UMMPParameter *parameter = [array objectAtIndex:rowIndex];
		
		NSMutableArray *parameters = [self findParametersByTag:[preset presetTag] forAlgorithm:algorithmTitle];
		
		int *fixed;
		int *limited;
		double *limits;
		double *p;
		
		fixed = (int*)calloc(1, sizeof(int));
		limited = (int*)calloc(2, sizeof(int));
		limits = (double*)calloc(2, sizeof(double));
		p = (double*)calloc(1, sizeof(double));
        
		if ([[aTableColumn identifier] isEqualToString: @"fixed"])
		{
			[parameter setValue:anObject forKey:[aTableColumn identifier]];
			double v = [[parameters objectAtIndex:rowIndex] fixed];
			NSNumber* versuch = [NSNumber numberWithDouble:v];
			[parameter setValue:versuch forKey:@"fixed"];
			
			[parametersTableView setNeedsDisplay:YES];
			
		}
		else if([[parameters objectAtIndex:rowIndex] fixed]){
			NSRunAlertPanel(@"Cannot change values", @"Table data can not be changed while \"fixed\" is checked!", @"OK", nil, nil);
		}
		else
		{
			[parameter setValue:anObject forKey:[aTableColumn identifier]];
            
			if ([[aTableColumn identifier] isEqualToString: @"pValue"])
			{
				if([[parameters objectAtIndex:rowIndex] limitedLow])
				{
					if([[parameters objectAtIndex:rowIndex] pValue] < [[parameters objectAtIndex:rowIndex] low])
					{
						double v = [[parameters objectAtIndex:rowIndex] low];
						NSNumber* versuch = [NSNumber numberWithDouble:v];
						[parameter setValue:versuch forKey:@"pValue"];
					}
				}
				if([[parameters objectAtIndex:rowIndex] limitedHigh])
				{
					if([[parameters objectAtIndex:rowIndex] pValue] > [[parameters objectAtIndex:rowIndex] high])
					{
						double v = [[parameters objectAtIndex:rowIndex] high];
						NSNumber* versuch = [NSNumber numberWithDouble:v];
						[parameter setValue:versuch forKey:@"pValue"];
					}
				}
			}
			
			
			if ([[aTableColumn identifier] isEqualToString: @"high"])
			{
				if([[parameters objectAtIndex:rowIndex] limitedHigh])
				{
					if([[parameters objectAtIndex:rowIndex] pValue] > [[parameters objectAtIndex:rowIndex] high])
					{
						double v = [[parameters objectAtIndex:rowIndex] high];
						NSNumber* versuch = [NSNumber numberWithDouble:v];
						[parameter setValue:versuch forKey:@"pValue"];
					}
					if(([[parameters objectAtIndex:rowIndex] high] < [[parameters objectAtIndex:rowIndex] low]) && [[parameters objectAtIndex:rowIndex] limitedLow])
					{
						double v = [[parameters objectAtIndex:rowIndex] low];
						NSNumber* versuch = [NSNumber numberWithDouble:v];
						[parameter setValue:versuch forKey:@"high"];
						[parameter setValue:versuch forKey:@"pValue"];
					}
				}
			}
			
			
			if ([[aTableColumn identifier] isEqualToString: @"low"])
			{
				if([[parameters objectAtIndex:rowIndex] limitedLow])
				{
					if([[parameters objectAtIndex:rowIndex] pValue] < [[parameters objectAtIndex:rowIndex] low])
					{
						double v = [[parameters objectAtIndex:rowIndex] low];
						NSNumber* versuch = [NSNumber numberWithDouble:v];
						[parameter setValue:versuch forKey:@"pValue"];
					}
					if(([[parameters objectAtIndex:rowIndex] high] < [[parameters objectAtIndex:rowIndex] low]) &&[[parameters objectAtIndex:rowIndex] limitedHigh])
					{
						double v = [[parameters objectAtIndex:rowIndex] high];
						NSNumber* versuch = [NSNumber numberWithDouble:v];
						[parameter setValue:versuch forKey:@"low"];
						[parameter setValue:versuch forKey:@"pValue"];
					}
				}
			}
			
			if ([[aTableColumn identifier] isEqualToString: @"limitedHigh"])
			{
				if([[parameters objectAtIndex:rowIndex] limitedHigh])
				{
					if([[parameters objectAtIndex:rowIndex] pValue] > [[parameters objectAtIndex:rowIndex] high])
					{
						double v = [[parameters objectAtIndex:rowIndex] high];
						NSNumber* versuch = [NSNumber numberWithDouble:v];
						[parameter setValue:versuch forKey:@"pValue"];
					}
					if(([[parameters objectAtIndex:rowIndex] high] < [[parameters objectAtIndex:rowIndex] low]) && [[parameters objectAtIndex:rowIndex] limitedLow])
					{
						double v = [[parameters objectAtIndex:rowIndex] low];
						NSNumber* versuch = [NSNumber numberWithDouble:v];
						[parameter setValue:versuch forKey:@"high"];
						[parameter setValue:versuch forKey:@"pValue"];
					}
				}
			}
			
			if ([[aTableColumn identifier] isEqualToString: @"limitedLow"])
			{
				NSLog(@"limitedLow");
				if([[parameters objectAtIndex:rowIndex] limitedLow])
				{
					if([[parameters objectAtIndex:rowIndex] pValue] < [[parameters objectAtIndex:rowIndex] low])
					{
						NSLog(@"limitedLow erste if abfrage");
						double v = [[parameters objectAtIndex:rowIndex] low];
						NSNumber* versuch = [NSNumber numberWithDouble:v];
						[parameter setValue:versuch forKey:@"pValue"];
					}
					if(([[parameters objectAtIndex:rowIndex] high] < [[parameters objectAtIndex:rowIndex] low]) &&[[parameters objectAtIndex:rowIndex] limitedHigh])
					{
						double v = [[parameters objectAtIndex:rowIndex] high];
						NSNumber* versuch = [NSNumber numberWithDouble:v];
						[parameter setValue:versuch forKey:@"low"];
						[parameter setValue:versuch forKey:@"pValue"];
					}
				}
			}
		}
		[parametersTableView setNeedsDisplay:YES];
		
		free(p);
		free(fixed);
		free(limited);
		free(limits);
		
    }
}

- (BOOL)tableView:(NSTableView *)tableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
     toPasteboard:(NSPasteboard *)pboard
{
    if (tableView == presetsTableView) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
        [pboard declareTypes:[NSArray arrayWithObject:PresetsTableViewDataType]
                       owner:self];
        [pboard setData:data forType:PresetsTableViewDataType];
        return YES;
    } else {
        return NO;
    }
}

- (NSDragOperation)tableView:(NSTableView *)tableView
                validateDrop:(id<NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    if (tableView == presetsTableView)
        return (dropOperation == NSTableViewDropAbove) ? NSDragOperationMove : NSDragOperationNone;
    else
        return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView
       acceptDrop:(id<NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)dropOperation
{
    NSPasteboard *pboard = [info draggingPasteboard];
    NSData *rowData = [pboard dataForType:PresetsTableViewDataType];
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    
    if (tableView == presetsTableView) {
        NSInteger aboveInsertIndexCount = 0;
        NSInteger removeIndex = 0;
        
        NSInteger dragRow = [rowIndexes lastIndex];
        while (dragRow != NSNotFound) {
            if (dragRow >= row) {
                removeIndex = dragRow + aboveInsertIndexCount;
                aboveInsertIndexCount++;
            } else {
                removeIndex = dragRow;
                row--;
            }
            UMMPPreset *preset = [presets objectAtIndex:removeIndex];
            [preset retain];
            [presets removeObjectAtIndex:removeIndex];
            [presets insertObject:preset atIndex:row];
            [preset release];
            
            dragRow =[rowIndexes indexLessThanIndex:dragRow];
        }
        [tableView reloadData];
        NSRange range = NSMakeRange(row, [rowIndexes count]);
        NSIndexSet *newSelection = [NSIndexSet indexSetWithIndexesInRange:range];
        [presetsTableView selectRowIndexes:newSelection
                      byExtendingSelection:NO];
        [parametersTableView reloadData];
        [[panelController algorithmController] loadPresets:presets];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark -

- (void)setRemoveButtonState
{
    if ([presets count] > 1)
        [removeButton setEnabled:YES];
    else
        [removeButton setEnabled:NO];
}

- (NSMutableArray*)findParametersByTag:(NSInteger)tag forAlgorithm:(NSString*)algorithm
{
    for (UMMPPreset *tmpPreset in presets)
        if ([tmpPreset presetTag] == tag)
            return [[tmpPreset algorithms] objectForKey:algorithm];
    
    return nil;
}

#pragma mark -
#pragma mark new methods

- (IBAction)changeView:(id)sender
{
    NSToolbarItemGroup *item = sender;
    NSInteger tag = [item tag];
    
    [self changeViewForTag: tag];
}

- (IBAction)setDefaultParameters:(id)sender
{
}

- (void)changeViewForTag:(NSInteger)preferences
{
    NSView *newView = nil;
    NSWindow *window = [self window];
    
    NSRect windowFrame = [[self window] frame];
    NSSize currentSize = windowFrame.size;
    
    float newSizeWidth = 0.0;
    float newSizeHeight = 0.0;
    float deltaWidth = 0.0;
    float deltaHeight = 0.0;
    
    switch (preferences) {
        case general:
            newView = _general;
            break;
        case presetValues:
            newView = _presetValues;
            break;
        case mapSelection:
            newView = _mapSelections;
            [self refreshStatusOfMapSelection];
            break;
        case mpFit:
            newView = _mpFit;
            break;
        case aifImport:
            
            // check if algorithm is choosed
            if ([panelController algorithmIsChoosed]) {
                
                // check if external AIF already exists 
                if (extROIExists) {
                    int choice = NSRunAlertPanel(@"Attention: Only one external ROI can be used", @"Do you want to delete the existing external ROI to load a new external ROI?", @"NO",@"YES",nil);
                    if (choice == deleteExternalAIF) {
                        [self deleteExternalAIF];
                        [self loadExternalAIF];
                        newView = _general;
                    }
                    newView = _general;
                } else {
                    [self loadExternalAIF];
                    newView = _general;
                }
            } else {
                NSRunAlertPanel(@"External AIF can not be load", @"Please choose an algorithm at first, before loading the external AIF", @"OK",nil,nil);
                newView = _general;
            }
            break;
        default:
            break;
    }
    
    newSizeWidth = newView.frame.size.width;
    newSizeHeight = newView.frame.size.height;
    deltaWidth = newSizeWidth - currentSize.width;
    deltaHeight = newSizeHeight - currentSize.height + 78.0; // 63.0 is the toolbar height
    
    windowFrame.size.height += deltaHeight;
    windowFrame.origin.y -= deltaHeight;
    windowFrame.size.width += deltaWidth;
    
    
    [window setContentView: NULL];
    [window setFrame: windowFrame display: YES animate: YES];
    [window setContentView: newView];
}

-(IBAction)pushMapSelButtonState:(id)sender
{
    [[panelController userDefaults] setBool:[sender state] forKey:[sender title]];
}

-(IBAction)pushButtonOnGeneralSettings:(id)sender
{
    if (sender == soundOnMapsCalcEnd) {
        [[panelController userDefaults] setInt:[soundOnMapsCalcEnd state] forKey:@"soundOnMapsCalcEnd"];
    }
    if (sender == soundOnAllMapsCalcEnd) {
        [[panelController userDefaults] setInt:[soundOnAllMapsCalcEnd state] forKey:@"soundOnAllMapsCalcEnd"];
    }
    if (sender == printPresetsToConsole) {
        [[panelController userDefaults] setInt:[printPresetsToConsole state] forKey:@"printPresetsToConsole"];
    }
    
}

-(IBAction)changeMPFitValues:(id)sender
{
    if ([[sender identifier]isEqualToString:@"maxiter"]) {
        [[panelController userDefaults] setString:[sender stringValue] forKey:@"UMMPMaxIterations"];
    }
    if ([[sender identifier]isEqualToString:@"maxfev"]) {
        [[panelController userDefaults] setString:[sender stringValue] forKey:@"UMMPMaxFunctionEvaluation"];
    }
}

-(void) refreshStatusOfMapSelection
{
    // Compartmentview
    [compartmentMapPF setState:[[panelController userDefaults] bool:@"UMMPcompartmentMapPF" otherwise:0]];
    [compartmentMapPMTT setState:[[panelController userDefaults] bool:@"UMMPcompartmentMapPMTT" otherwise:0]];
    [compartmentMapPV setState:[[panelController userDefaults] bool:@"UMMPcompartmentMapPV" otherwise:0]];
    [compartmentMapAFE setState:[[panelController userDefaults] bool:@"UMMPcompartmentMapAFE" otherwise:0]];
    [compartmentMapCS setState:[[panelController userDefaults] bool:@"UMMPcompartmentMapCS" otherwise:0]];
    
    // 2C Exchangeview
    [exchangeMapPF setState:[[panelController userDefaults] bool:@"UMMPexchangeMapPF" otherwise:0]];
    [exchangeMapPMTT setState:[[panelController userDefaults] bool:@"UMMPexchangeMapPMTT" otherwise:0]];
    [exchangeMapPV setState:[[panelController userDefaults] bool:@"UMMPexchangeMapPV" otherwise:0]];
    [exchangeMapIMTT setState:[[panelController userDefaults] bool:@"UMMPexchangeMapIMTT" otherwise:0]];
    [exchangeMapIV setState:[[panelController userDefaults] bool:@"UMMPexchangeMapIV" otherwise:0]];
    [exchangeMapEF setState:[[panelController userDefaults] bool:@"UMMPexchangeMapEF" otherwise:0]];
    [exchangeMapPSAP setState:[[panelController userDefaults] bool:@"UMMPexchangeMapPSAP" otherwise:0]];
    [exchangeMapAFE setState:[[panelController userDefaults] bool:@"UMMPexchangeMapAFE" otherwise:0]];
    [exchangeMapCS setState:[[panelController userDefaults] bool:@"UMMPexchangeMapCS" otherwise:0]];
    
    // 2C Filtrationview
    [filtrationMapPF setState:[[panelController userDefaults] bool:@"UMMPfiltrationMapPF" otherwise:0]];
    [filtrationMapPMTT setState:[[panelController userDefaults] bool:@"UMMPfiltrationMapPMTT" otherwise:0]];
    [filtrationMapPV setState:[[panelController userDefaults] bool:@"UMMPfiltrationMapPV" otherwise:0]];
    [filtrationMapIMTT setState:[[panelController userDefaults] bool:@"UMMPfiltrationMapIMTT" otherwise:0]];
    [filtrationMapEF setState:[[panelController userDefaults] bool:@"UMMPfiltrationMapEF" otherwise:0]];
    [filtrationMapPSAP setState:[[panelController userDefaults] bool:@"UMMPfiltrationMapPSAP" otherwise:0]];
    [filtrationMapAFE setState:[[panelController userDefaults] bool:@"UMMPfiltrationMapAFE" otherwise:0]];
    [filtrationMapCS setState:[[panelController userDefaults] bool:@"UMMPfiltrationMapCS" otherwise:0]];
    
    // 2C Uptakeview
    [uptakeMapPF setState:[[panelController userDefaults] bool:@"UMMPuptakeMapPF" otherwise:0]];
    [uptakeMapPMTT setState:[[panelController userDefaults] bool:@"UMMPuptakeMapPMTT" otherwise:0]];
    [uptakeMapPV setState:[[panelController userDefaults] bool:@"UMMPuptakeMapPV" otherwise:0]];
    [uptakeMapEF setState:[[panelController userDefaults] bool:@"UMMPuptakeMapEF" otherwise:0]];
    [uptakeMapPSAP setState:[[panelController userDefaults] bool:@"UMMPuptakeMapPSAP" otherwise:0]];
    [uptakeMapAFE setState:[[panelController userDefaults] bool:@"UMMPuptakeMapAFE" otherwise:0]];
    [uptakeMapCS setState:[[panelController userDefaults] bool:@"UMMPuptakeMapCS" otherwise:0]];
    
    // Modified Toftsview
    [toftsMapPV setState:[[panelController userDefaults] bool:@"UMMPtoftsMapPV" otherwise:0]];
    [toftsMapIMTT setState:[[panelController userDefaults] bool:@"UMMPtoftsMapIMTT" otherwise:0]];
    [toftsMapIV setState:[[panelController userDefaults] bool:@"UMMPtoftsMapIV" otherwise:0]];
    [toftsMapPSAP setState:[[panelController userDefaults] bool:@"UMMPtoftsMapPSAP" otherwise:0]];
    [toftsMapAFE setState:[[panelController userDefaults] bool:@"UMMPtoftsMapAFE" otherwise:0]];
    [toftsMapCS setState:[[panelController userDefaults] bool:@"UMMPtoftsMapCS" otherwise:0]];
    
}

#pragma mark -
#pragma mark file import / aif import


-(void)loadExternalAIF {
    
    if (!extROIExists) {
        
        // initialize an NSOpenPanel Window
        NSOpenPanel *openPanel	= [NSOpenPanel openPanel];
        
        // Enable options for the panel
        [openPanel setCanChooseFiles:YES];
        [openPanel setAllowsMultipleSelection:FALSE];
        
        // open the "NSOpenPanel Window" and check if the user clicked on ok button.
        if([openPanel runModal] == NSOKButton) {
            
            // get the directory of the choosen file
            NSURL *directory = [openPanel URL];
            
            // convert the directory of the file into a string
            NSString *filePath = [directory path];
            
            // create filepath for the UMMPerfusion report
            extROIFilePathForReport = [filePath mutableCopy];
            
            // with the Filemanager you can locate, move, copy, link remove or get information about files or directories
            NSFileManager *filemgr = [NSFileManager defaultManager];
            
            // check if the opened file is the correct one which is needed to create the external ROI
            if ([filePath hasSuffix:@".csv"]) {
                
                // check if the choosen file exists and check if is a readable file
                if ([filemgr fileExistsAtPath:filePath] && [filemgr isReadableFileAtPath:filePath]){
                    
                    NSData *databuffer = [filemgr contentsAtPath:filePath];
                    NSString* newStr = [[[NSString alloc] initWithData:databuffer
                                                              encoding:NSUTF8StringEncoding] autorelease];
                    
                    // creates an array with all values in the file
                    NSArray *substrings = [newStr componentsSeparatedByString:@";"];
                    
                    // check if the selected csv file is valid
                    if ([[substrings objectAtIndex:7] isEqualTo:@"aif"] || [[substrings objectAtIndex:2] isEqualTo:@"aif"]) {
                        
                        NSString *allAifValues;
                        NSString *currentAifValue;
                        
                        // index is 7 because the first aif value in the csv file is "objectAtIndex:7". The next aif value is "index + 6"
                        int index = 7;
                        
                        if ([[substrings objectAtIndex:7] isEqualTo:@"aif"]) {
                            
                            // if the csv file modified by the user, the first aif value is "objectAtIndex:12". The next aif value is "index + 5"
                            index = 12;
                            
                            while (index < [substrings count]) {
                                currentAifValue = [substrings objectAtIndex:index];
                                
                                if (index == 12) {
                                    allAifValues = [NSString stringWithFormat:@"%@", currentAifValue];
                                    index = index + 5;
                                    
                                } else {
                                    allAifValues = [NSString stringWithFormat:@"%@;%@", allAifValues, currentAifValue];
                                    index = index + 5;
                                }
                            }
                        } else {
                            
                            while (index < [substrings count]) {
                                currentAifValue = [substrings objectAtIndex:index];
                                
                                if (index == 7) {
                                    allAifValues = [NSString stringWithFormat:@"%@", currentAifValue];
                                    index = index + 6;
                                    
                                } else {
                                    allAifValues = [NSString stringWithFormat:@"%@;%@", allAifValues, currentAifValue];
                                    index = index + 6;
                                }
                            }
                        }
                        // creates an array only with the aif values
                        NSArray *aifData = [allAifValues componentsSeparatedByString:@";"];
                        
                        // check if the opened file has the same number of AIF values like the Timepoints of the 4-D dataset
                        if ([[panelController viewerController] maxMovieIndex] == [aifData count] && [[aifData objectAtIndex:[[panelController viewerController] maxMovieIndex]-1]floatValue] != 0.000000) {
                            
                            // mutable array to access from other classes
                            aifExportData = [aifData mutableCopy];
                            
                            // get the file name of the choosen file
                            NSString *filename = [filePath stringByDeletingPathExtension];
                            extROIFilename = [filename lastPathComponent];
                            
                            extROI = YES;
                            
                            extROIExists = YES;
                            
                            externalROI = [[ROI alloc] init];
                            
                            // creates an external ROIRec
                            UMMPROIRec *artROIRec = [[panelController roiList] createRoiRecForRoi:externalROI];
                            
                            // add externalROI into the ROI list
                            [[panelController algorithmController] addROIRec:artROIRec];
                            
                            // close preferences panel after importing the external ROI
                            [[self window] close];
                            
                            NSRunAlertPanel(@"External ROI loaded", @"The name of the external ROI is the same as for the selected csv file", @"OK", nil, nil);
                        } else {
                            NSRunAlertPanel(@"Invalid csv file", @"Number of AIF values not equal to the 4-D dataset Timepoints number", @"OK", nil, nil);                        }
                    } else {
                        NSRunAlertPanel(@"Invalid csv file", @"Please choose a supported csv file", @"OK", nil, nil);
                    }
                }
            }
            // if the choosen file is not a csv file then open an alert window
            else if(![filePath hasSuffix:@".csv"]) {
                
                NSRunAlertPanel(@"Invalid file type", @"Only csv files are supported", @"OK", nil, nil);
            }
        }
    } else {
        // Alert by trying to load another external ROI when a external ROI already exists
        NSRunAlertPanel(@"External ROI already exists", @"Only one external ROI can be loaded. Delete the existing external ROI to load another one", @"OK", nil, nil);
    }
}


-(float)getAifValue:(int)i {
    float aifValue;
    
    aifValue = [[aifExportData objectAtIndex:i] floatValue];
    
    return aifValue;
}

-(void)deleteExternalAIF {
    [[panelController roiList] removeExternalRoi:externalROI];
    [[panelController algorithmController] loadROIRecs:[[panelController roiList] records]];
    extROIExists = NO;
}

@end
